//
//  WeatherTableViewCell.swift
//  WeatherApp2
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
import SwiftUI
class WeatherTableViewCell: UITableViewCell {
    
    var weatherListView: UIHostingController<WeatherListCell>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWeatherListView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWeatherListView() {
        let weatherListCell = WeatherListCell(title: "", value: "")
        weatherListView = UIHostingController(rootView: weatherListCell)
        if let listView = weatherListView {
            addSubview(listView.view)
            listView.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                listView.view.topAnchor.constraint(equalTo: topAnchor),
                listView.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                listView.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                listView.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
    }
}

struct WeatherListCell: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).font(.system(size: 25))
            Spacer()
            Text(value).font(.system(size: 25))
        }.padding()
    }
}
