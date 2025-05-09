//
//  DomaCacheProtocol.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import Foundation

public protocol DomaCacheProtocol {
    func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async
    func clear() async
}

public final class DomaCache: DomaCacheProtocol {
    //static let shared = DomaCache()

    private let memoryCache = NSCache<NSString, CacheEntry<Data>>()
    private let fileManager = FileManager.default
    private let directoryURL: URL

    public init() {
        if let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.directoryURL = cachesDirectory.appendingPathComponent("DomaCache")
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } else {
            fatalError("Unable to access caches directory")
        }
    }

    public func save<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        let cacheEntry = CacheEntry(value: data, expiration: expiration)

        memoryCache.setObject(cacheEntry, forKey: key as NSString)
        let url = fileURL(forKey: key)
        try await saveToDisk(entry: cacheEntry, at: url)
    }

    public func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        if let entry = memoryCache.object(forKey: key as NSString), !entry.isExpired {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: entry.value)
        }

        let url = fileURL(forKey: key)
        guard let entry = try await loadFromDisk(at: url), !entry.isExpired else {
            return nil
        }

        memoryCache.setObject(entry, forKey: key as NSString)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: entry.value)
    }

    public func remove(forKey key: String) async {
        memoryCache.removeObject(forKey: key as NSString)
        let url = fileURL(forKey: key)
        try? fileManager.removeItem(at: url)
    }

    public func clear() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: directoryURL)
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    // MARK: - Private

    private func fileURL(forKey key: String) -> URL {
        return directoryURL.appendingPathComponent(key.sha256())
    }

    private func saveToDisk(entry: CacheEntry<Data>, at url: URL) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(entry)
        try data.write(to: url)
    }

    private func loadFromDisk(at url: URL) async throws -> CacheEntry<Data>? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(CacheEntry<Data>.self, from: data)
    }
}
