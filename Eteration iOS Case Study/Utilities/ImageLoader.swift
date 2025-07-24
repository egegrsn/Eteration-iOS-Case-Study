//
//  ImageLoader.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 22.07.2025.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    func loadImage(from url: URL) async throws -> UIImage {
        // Check cache
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Download image
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageLoader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data is not a valid image"])
        }

        // Cache it
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
}
