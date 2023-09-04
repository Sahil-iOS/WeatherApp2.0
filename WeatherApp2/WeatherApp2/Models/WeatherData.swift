//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
struct WeatherData: Codable {
    
    struct Weather: Codable {
        let title: String
        let description: String
        let icon: String
        
        //use of codingkeys so that main can be renamed to title for better readability
        enum CodingKeys: String, CodingKey {
            case title = "main"
            case description
            case icon
        }
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
    }
    
    let weather: [Weather]
    let main: Main
}
