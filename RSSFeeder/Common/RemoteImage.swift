//
//  RemoteImage.swift
//  RSSFeeder
//
//  Created by Dino Franic on 17.06.2021..
//

import SwiftUI
import Combine

struct RemoteImage: View {
    @ObservedObject private var imageLoader: ImageLoader
    
    init(url: String) {
        imageLoader = ImageLoader(url:url)
    }
    
    var body: some View {
        Image(uiImage: imageLoader.image)
            .resizable()
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage = UIImage()
    
    let url: String
    let imageCache = ImageCache.shared
    
    init(url:String) {
        self.url = url
        
        if let image = loadImageFromCache() {
            self.image = image
        } else {
            self.loadImageFromUrl()
        }
    }

    private func loadImageFromCache() -> UIImage? {
        guard let cachedImage = imageCache.get(forKey: url) else {
            return nil
        }
        
        return cachedImage
    }
    
    private func loadImageFromUrl() {
        guard let url = URL(string: self.url) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data)!
                self.imageCache.set(forKey: self.url, image: self.image)
            }
        }
        task.resume()
    }
}

struct ImageCache {
    static let shared = ImageCache()
    
    var cache = NSCache<NSString, UIImage>()
    
    private init() {
    }
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://static.rtl.lu/rtl/layout/logo_rtl.png")
    }
}
