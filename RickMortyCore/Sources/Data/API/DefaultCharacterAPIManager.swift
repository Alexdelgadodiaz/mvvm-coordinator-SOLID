//
//  ApolloCharacterAPIManager.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import Foundation
import RickMortyShared
import RickMortyModels

public final class DefaultCharacterAPIManager: CharacterAPIManagerProtocol {

    private let baseURL: String
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let logger: LoggerProtocol

    private enum Constants {
        static let timeoutInterval: TimeInterval = 15
    }

    public init(
        baseURL: String = "https://rickandmortyapi.com/api/",
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: LoggerProtocol = DefaultLogger()
    ) {
        self.baseURL = baseURL
        self.urlSession = session
        self.decoder = decoder
        self.logger = logger
    }

    // MARK: - Public Interface

    public func fetchCharacters(page: Int, filter: String?) async throws -> PaginatedCharacters {
        let response: CharactersResponse = try await fetchPaginated(endpoint: "character", page: page, filter: filter)
        let characters = response.results.map { CharacterModel(apiModel: $0) }
        return PaginatedCharacters(characters: characters, hasNextPage: response.info.next != nil)
    }

    public func fetchEpisodes(page: Int, filter: String?) async throws -> PaginatedEpisodes {
        let response: EpisodesResponse = try await fetchPaginated(endpoint: "episode", page: page, filter: filter)
        let episodes = response.results.map { EpisodeModel(apiModel: $0) }
        return PaginatedEpisodes(episodes: episodes, hasNextPage: response.info.next != nil)
    }

    public func fetchCharacters(for urls: [String]) async throws -> [CharacterModel] {
        let apiModels: [CharacterAPIModel] = try await fetchMultipleItems(from: urls)
        return apiModels.map { CharacterModel(apiModel: $0) }
    }

    public func fetchEpisodes(for urls: [String]) async throws -> [EpisodeModel] {
        let apiModels: [EpisodeAPIModel] = try await fetchMultipleItems(from: urls)
        return apiModels.map { EpisodeModel(apiModel: $0) }
    }

    // MARK: - Private Helpers

    private func fetchPaginated<T: Decodable>(endpoint: String, page: Int, filter: String?) async throws -> T {
        let url = try buildURL(endpoint: endpoint, page: page, filter: filter)
        let request = makeRequest(url: url)

        logger.logInfo("[NETWORK] Fetching \(endpoint.uppercased()) page \(page)")
        let (data, response) = try await urlSession.data(for: request)

        try validate(response: response)

        return try decoder.decode(T.self, from: data)
    }

    private func fetchMultipleItems<T: Sendable & Decodable>(from urls: [String]) async throws -> [T] {
        var items: [T] = []
        
        for url in urls {
            guard let url = URL(string: url) else {
                logger.logError("Invalid URL: \(url)")
                continue
            }

            let request = makeRequest(url: url)
            let (data, _) = try await urlSession.data(for: request)

            do {
                let item = try decoder.decode(T.self, from: data)
                items.append(item)
            } catch {
                logger.logError("Failed to decode item from \(url): \(error)")
            }
        }

        return items
    }

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = Constants.timeoutInterval
        return request
    }

    private func buildURL(endpoint: String, page: Int, filter: String?) throws -> URL {
        var components = URLComponents(string: baseURL + endpoint)!
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        if let filter = filter?.trimmingCharacters(in: .whitespacesAndNewlines), !filter.isEmpty {
            guard let encodedFilter = filter.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                throw APIError.invalidURL
            }
            queryItems.append(URLQueryItem(name: "name", value: encodedFilter))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        return url
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300: return
        case 400..<500: throw APIError.clientError(httpResponse.statusCode)
        case 500..<600: throw APIError.serverError(httpResponse.statusCode)
        default: throw APIError.unexpectedStatusCode(httpResponse.statusCode)
        }
    }
}
