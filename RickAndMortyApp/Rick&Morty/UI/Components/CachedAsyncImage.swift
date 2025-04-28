//
//  CachedAsyncImage.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//


import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    let url: URL
    @ViewBuilder var content: (Image) -> Content
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                ProgressView()
                    .task { await loadImage() }
            }
        }
    }

    @MainActor
    private func loadImage() async {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            print("🟢 [CACHE] image \(url.lastPathComponent)")
            self.image = image
            return
        }

        print("🔴 [RED] Fetching image \(url.lastPathComponent)")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let image = UIImage(data: data) else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)

            self.image = image
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}