//
//  WeatherTableHeaderViewCell.swift
//  WeatherApp2
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
import SwiftUI

struct WeatherTableHeaderViewCell: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        if let data = viewModel.weatherData {
            VStack {
                Text("\((viewModel.location?.name ?? "").capitalized)")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 35))
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
                
                WeatherImageView(url: viewModel.createImageURL())
                
                Text("\(data.main.temp.kelvinToFarenheit())")
                    .font(.system(size: 100))
                
                Text("\((data.weather[0].description).capitalized)")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 35))
            }
        } else {
            EmptyView() // Placeholder view when data is not available
        }
    }
}
