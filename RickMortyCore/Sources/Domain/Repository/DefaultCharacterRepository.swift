//
//  DefaultCharacterRepository.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//
import Foundation
import RickMortyModels
import RickMortyShared
import RickMortyAPI


public final class DefaultCharacterRepository: CharacterRepositoryProtocol {
    private let apiManager: CharacterAPIManagerProtocol
    private let memoryCache = NSCache<NSString, CacheEntry<PaginatedCharacters>>()
    private let memoryCacheEpisodes = NSCache<NSString, CacheEntry<[EpisodeModel]>>()
    private let cacheLifetime: TimeInterval = 300 // 5 minutos
    private let domaCache : DomaCache

    public init(apiManager: CharacterAPIManagerProtocol, domaCache: DomaCache) {
        self.apiManager = apiManager
        self.domaCache = domaCache // Inyección de dependencia
    }

    public func getCharacters(page: Int, filter: String?) async throws -> PaginatedCharacters {
        let cacheKey = "characters_page_\(page)_\(filter ?? "")" as NSString
        if let entry = memoryCache.object(forKey: cacheKey), !entry.isExpired {
            print("🟢 [CACHE] Characters loaded from memory for page \(page), filter: \(filter ?? "none")")
            return entry.value
        }
        if let diskData: PaginatedCharacters = try await domaCache.load(PaginatedCharacters.self, forKey: cacheKey as String) {
            print("🟢 [CACHE - Disk] Characters loaded from disk for page \(page), filter: \(filter ?? "none")")
            memoryCache.setObject(CacheEntry(value: diskData, expiration: cacheLifetime), forKey: cacheKey)
            return diskData
        }

        print("🔴 [NETWORK] Fetching Characters from network for page \(page), filter: \(filter ?? "none")")
        let characters = try await apiManager.fetchCharacters(page: page, filter: filter)
        memoryCache.setObject(CacheEntry(value: characters, expiration: cacheLifetime), forKey: cacheKey)
        try await domaCache.save(characters, forKey: cacheKey as String, expiration: cacheLifetime)
        return characters
    }

    public func getEpisodes(from urls: [String]) async throws -> [EpisodeModel] {
        let cacheKey = "episodes_urls_\(urls.joined(separator: "_"))" as NSString
        if let entry = memoryCacheEpisodes.object(forKey: cacheKey), !entry.isExpired {
            print("🟢 [CACHE] Episodes loaded from memory for urls: \(urls)")
            return entry.value
        }
        if let diskData: [EpisodeModel] = try await domaCache.load([EpisodeModel].self, forKey: cacheKey as String) {
            print("🟢 [CACHE - Disk] Episodes loaded from disk for urls: \(urls)")
            memoryCacheEpisodes.setObject(CacheEntry(value: diskData, expiration: cacheLifetime), forKey: cacheKey)
            return diskData
        }

        print("🔴 [NETWORK] Fetching Episodes from network for urls: \(urls)")
        let episodes = try await apiManager.fetchEpisodes(for: urls)
        memoryCacheEpisodes.setObject(CacheEntry(value: episodes, expiration: cacheLifetime), forKey: cacheKey)
        try await domaCache.save(episodes, forKey: cacheKey as String, expiration: cacheLifetime)
        return episodes
    }
}
