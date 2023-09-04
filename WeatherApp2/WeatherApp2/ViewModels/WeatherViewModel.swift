//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Sahil Patel on 8/15/23.
//

import CoreLocation
import SwiftUI

protocol WeatherViewModelDelegate: AnyObject {
    func weatherDataDidUpdate()
    func alert(message: String)
}

class WeatherViewModel: NSObject, ObservableObject {
    let states = [ "","AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT","VA","VI","VT","WA","WI","WV","WY"]
    
    @Published var city = ""
    @Published var state = ""
    @Published var zip = ""
    @Published var weatherDataDetails : [(String, String?)] = []
    @Published var inputMode: InputMode = .cityState
    @Published var location: Location?
    @Published var weatherData: WeatherData? {
        didSet {
            delegate?.weatherDataDidUpdate()
        }
    }
    
    private var locationManager = CLLocationManager()
    private let userDefaults = UserDefaults.standard
    private let weatherProvider: WeatherDataProvider
    private let geocodingProvider: GeocodingDataProvider
    weak var delegate: WeatherViewModelDelegate?
    
    init(geocodingDataProvider: GeocodingDataProvider, weatherDataProvider: WeatherDataProvider) {
        self.geocodingProvider = geocodingDataProvider
        self.weatherProvider = weatherDataProvider
        super.init()
        self.locationManager.delegate = self
    }
    
    //Fetch old location from user defaults
    func fetchSavedWeatherData() async {
        if let storedData = UserDefaults.standard.data(forKey: "location"), let decodedLocation = try? JSONDecoder().decode(Location.self, from: storedData) {
            DispatchQueue.main.async {
                self.location = decodedLocation
            }
            if !(decodedLocation.lat == 0.0 && decodedLocation.lon == 0.0) {
                await fetchWeatherData(lat: decodedLocation.lat, lon: decodedLocation.lon)
            }
        }
    }
    
    //To fetch weather data we need to first get the lat long values using the geocoding api and handle the request based on the input provided
    func fetchLatLong() async {
        do {
            var loc: Location?
            if inputMode == .cityState {
                loc = try await geocodingProvider.geocode(city: city, state: state)
            } else if inputMode == .zip {
                loc = try await geocodingProvider.geocode(zip: zip)
            }
            
            self.saveLocation(location: loc)
            if let location = loc {
                await fetchWeatherData(lat: location.lat, lon: location.lon)
            }
            
        } catch {
            self.delegate?.alert(message: error.localizedDescription)
        }
    }
    
    //once we have a latitude and longitude we can call the weather api to get the data and display it by assigning the data to weatherData
    func fetchWeatherData(lat: Double, lon: Double) async {
        do {
            let data = try await weatherProvider.fetchWeatherData(latitude: lat, longitude: lon)
            DispatchQueue.main.async {
                self.weatherData = data
                self.weatherDataDetails = [("Feels Like", self.weatherData?.main.feelsLike.kelvinToFarenheit()),
                                           ("Today's Low", self.weatherData?.main.tempMin.kelvinToFarenheit()),
                                           ("Today's High", self.weatherData?.main.tempMax.kelvinToFarenheit()),
                                           ("Humidity", "\(self.weatherData?.main.humidity ?? 0) %")]
            }
        } catch {
            self.delegate?.alert(message: error.localizedDescription)
        }
    }
    
    func verifyInputs() -> Bool {
        if inputMode == .cityState {
            if city == "" {
                self.delegate?.alert(message: "Please enter a city")
                return false
            }
            if state == "" {
                self.delegate?.alert(message: "Please select a state")
                return false
            }
        } else {
            if zip == "" {
                self.delegate?.alert(message: "Please enter a zip code")
                return false
            }
        }
        
        return true
    }
    
    func clearInputs(inputMode: InputMode) {
        if inputMode == .zip {
            city = ""
            state = ""
        } else {
            zip = ""
        }
    }
    
    func saveLocation(location: Location?) {
        guard let location else {
            self.delegate?.alert(message: "Error fetching location")
            return
        }
        
        DispatchQueue.main.async {
            //save the coordinates in user defaults to retain the last searched location
            self.location = location
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(self.location) {
                UserDefaults.standard.set(encodedData, forKey: "location")
            }
        }
    }
    
    func fetchCurrentLocationData() async {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways :
            if inputMode == .currentLocation {
                locationManager.startUpdatingLocation()
                let lastLocation = locationManager.location
                let lat = lastLocation?.coordinate.latitude ?? 0.0
                let lon = lastLocation?.coordinate.longitude ?? 0.0
                locationManager.stopUpdatingLocation()
                
                if !(lat == 0.0 && lon == 0.0) {
                    do {
                        let loc = try await geocodingProvider.geocode(lat: String(lat), lon: String(lon))
                        self.saveLocation(location: loc)
                        Task(priority: .background){
                            await fetchWeatherData(lat: lat, lon: lon)
                        }
                        
                    } catch {
                        self.delegate?.alert(message: error.localizedDescription)
                    }
                }
            }
            
        case .denied, .restricted:
            self.delegate?.alert(message: "Please enable location access from settings to access this feature")
        default:
            break
        }
    }
    
    func createImageURL() -> URL?{
        if let code = weatherData?.weather.first?.icon {
            return URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png")
        }
        return nil
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways :
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
}

extension Double {
    func kelvinToFarenheit() -> String {
        let f = (self - 273.15) * 9/5 + 32
        let roundedF = Int(f.rounded())
        return "\(roundedF)°F"
    }
}
