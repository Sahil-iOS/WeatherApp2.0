//
//  ViewController.swift
//  WeatherApp2
//
//  Created by Sahil Patel on 9/3/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    private let apiKey = "41c4d579910b3c09f1256adb9d019810"
    private var viewModel: WeatherViewModel
    let tableView = UITableView()
    
    required init(coder: NSCoder){
        self.viewModel = WeatherViewModel(geocodingDataProvider: OpenWeatherGeocoder(apiKey: apiKey), weatherDataProvider: OpenWeatherData(apiKey: apiKey))
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.delegate = self
        Task(priority: .background) {
            await viewModel.fetchSavedWeatherData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Segmneted picker
        let segmentedPickerHostingController = UIHostingController(rootView: SegmentedPickerView(viewModel: viewModel))
        addChild(segmentedPickerHostingController)
        view.addSubview(segmentedPickerHostingController.view)
        segmentedPickerHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedPickerHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedPickerHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedPickerHostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        segmentedPickerHostingController.didMove(toParent: self)
        
        //User Input fields
        let locationInputHostingController = UIHostingController(rootView: LocationInputView(viewModel: viewModel))
        addChild(locationInputHostingController)
        view.addSubview(locationInputHostingController.view)
        locationInputHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationInputHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationInputHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationInputHostingController.view.topAnchor.constraint(equalTo: segmentedPickerHostingController.view.bottomAnchor),
        ])
        locationInputHostingController.didMove(toParent: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: locationInputHostingController.view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        //Tableview header to display image temperature and description
        let headerView = WeatherTableHeaderViewCell(viewModel: viewModel)
        let headerController = UIHostingController(rootView: headerView)
        headerController.view.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 400)
        tableView.tableHeaderView = headerController.view
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.weatherData == nil ? 0 : 4 //Hide tableview if weatherData is nil or else show the 4 details rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherTableViewCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.weatherDataDetails[indexPath.row]
        cell.weatherListView?.rootView = WeatherListCell(title: item.0, value: item.1 ?? "")
        
        return cell
    }
}

extension ViewController: WeatherViewModelDelegate {
    func weatherDataDidUpdate() {
        tableView.reloadData()
    }
    
    func alert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in
                    self.dismiss(animated: true)
                }
            ))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


