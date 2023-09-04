//
//  SegmentedPickerView.swift
//  WeatherApp
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
import SwiftUI
import UIKit

//to display the segmented control and determine which api to use
enum InputMode: String, CaseIterable, Identifiable {
    case cityState = "City & State"
    case zip = "Zip Code"
    case currentLocation = "Current Location"
    var id: String { self.rawValue }
}

struct SegmentedPickerView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        Picker("Input Mode", selection: $viewModel.inputMode) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Text(mode.rawValue)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: viewModel.inputMode) { newValue in
            viewModel.clearInputs(inputMode: newValue)
            if newValue == .currentLocation {
                Task(priority: .background) {
                   await viewModel.fetchCurrentLocationData()
                }
            }
        }
    }
}
