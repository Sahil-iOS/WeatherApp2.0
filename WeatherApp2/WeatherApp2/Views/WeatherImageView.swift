//
//  WeatherImageView.swift
//  WeatherApp
//
//  Created by Sahil Patel on 9/3/23.
//

import Foundation
import SwiftUI
struct WeatherImageView: View {
    @State private var cachedImage: UIImage = UIImage()
    private var url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    //update the image whenever url changes and on appear to load it initially
    var body: some View {
        Image(uiImage: cachedImage)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: 250, maxHeight: 100)
            .onChange(of: url) { newURL in
                if let updatedURL = newURL {
                    Task(priority: .background) {
                        await loadImage(url: updatedURL)
                    }
                }
            }
            .onAppear {
                if let loadURL = url {
                    Task(priority: .background) {
                        await loadImage(url: loadURL)
                    }
                }
            }
    }
    
    func loadImage(url: URL) async {
        //load image if saved in cachae
        if let cache = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            DispatchQueue.main.async {
                cachedImage = UIImage(data: cache.data) ?? UIImage()
            }
        } else {
            do {
                //make a request and save response to cache
                let (data, response) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cachedImage = image
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        let cacheData = CachedURLResponse(response: httpResponse, data: data)
                        URLCache.shared.storeCachedResponse(cacheData, for: URLRequest(url: url))
                    }
                }
            } catch {
                return
            }
        }
    }
}
