//
//  CachedAsyncImage.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//


import SwiftUI
import RickMortyShared


struct CachedAsyncImage<Content: View>: View {
    let urlString: String
    @ViewBuilder var content: (Image) -> Content
    @State private var image: UIImage?
    private let logger: LoggerProtocol
    
    init(urlString: String, logger: LoggerProtocol = DefaultLogger(),   @ViewBuilder content: @escaping (Image) -> Content) {
        self.urlString = urlString
        self.content = content
        self.logger = logger
    }

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
        
        guard let url = URL(string: urlString) else {
            logger.logInfo("Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            print("🟢 [CACHE] image \(url.lastPathComponent)")
            self.image = image
            return
        }

        logger.logInfo("[NETWORK] Fetching image \(url.lastPathComponent)")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let image = UIImage(data: data) else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)

            self.image = image
        } catch {
            logger.logError("Error loading image: \(error.localizedDescription)")
        }
    }
}
