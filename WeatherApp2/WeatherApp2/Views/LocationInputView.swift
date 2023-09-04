//
//  LocationInputView.swift
//  WeatherApp
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
import SwiftUI

struct LocationInputView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            if viewModel.inputMode == .cityState {
                HStack {
                    TextField("City", text: $viewModel.city)
                        .padding()
                    
                    Picker("State", selection: $viewModel.state) {
                        ForEach(viewModel.states, id: \.self) { state in
                            state.isEmpty ? Text("State") : Text(state)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
            } else if viewModel.inputMode == .zip {
                TextField("Zip", text: $viewModel.zip)
                    .padding()
            }
            if viewModel.inputMode != .currentLocation {
                Button("Get Weather") {
                    Task(priority: .background) {
                        if viewModel.verifyInputs() {
                            await viewModel.fetchLatLong()
                        }
                    }
                }
            }
        }
    }
}

