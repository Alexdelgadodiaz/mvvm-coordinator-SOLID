//
//  DefaultEpisodeRepository.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//
import Foundation
import RickMortyAPI
import RickMortyModels

public final class DefaultEpisodeRepository: EpisodeRepositoryProtocol {
    private let apiManager: CharacterAPIManagerProtocol
    private let memoryCache = NSCache<NSString, CacheEntry<PaginatedEpisodes>>()
    private let cacheLifetime: TimeInterval = 300 // 5 minutos
    private let domaCache : DomaCacheProtocol

    public init(apiManager: CharacterAPIManagerProtocol, domaCache: DomaCacheProtocol) {
        self.apiManager = apiManager
        self.domaCache = domaCache // Inyección de dependencia
    }

    public func getEpisodes(page: Int, filter: String?) async throws -> PaginatedEpisodes {
        let cacheKey = "episodes_page_\(page)_\(filter ?? "")" as NSString
        if let entry = memoryCache.object(forKey: cacheKey), !entry.isExpired {
            print("🟢 [CACHE - Memory] Episodes loaded from memory for page \(page), filter: \(filter ?? "none")")
            return entry.value
        }

        if let diskData: PaginatedEpisodes = try await domaCache.load(PaginatedEpisodes.self, forKey: cacheKey as String) {
            print("🟢 [CACHE - Disk] Episodes loaded from disk for page \(page), filter: \(filter ?? "none")")
            memoryCache.setObject(CacheEntry(value: diskData, expiration: cacheLifetime), forKey: cacheKey)
            return diskData
        }

        print("🔴 [NETWORK] Fetching Episodes from network for page \(page), filter: \(filter ?? "none")")
        let episodes = try await apiManager.fetchEpisodes(page: page, filter: filter)
        memoryCache.setObject(CacheEntry(value: episodes, expiration: cacheLifetime), forKey: cacheKey)
        try await domaCache.save(episodes, forKey: cacheKey as String, expiration: cacheLifetime)
        return episodes
    }

    public func getCharacters(from urls: [String]) async throws -> [CharacterModel] {
        return try await apiManager.fetchCharacters(for: urls)
    }
}
