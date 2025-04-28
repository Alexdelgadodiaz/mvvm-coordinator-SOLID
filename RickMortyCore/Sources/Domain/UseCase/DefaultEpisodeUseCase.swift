//
//  DefaultEpisodeUseCase.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import RickMortyModels

public final class DefaultEpisodeUseCase: EpisodeUseCaseProtocol {
    private let repository: EpisodeRepositoryProtocol

    public init(repository: EpisodeRepositoryProtocol) {
        self.repository = repository
    }

    public func getEpisodes(page: Int, filter: String?) async throws -> PaginatedEpisodes {
        return try await repository.getEpisodes(page: page, filter: filter)
    }

    public func getCharacters(from urls: [String]) async throws -> [CharacterModel] {
        let batchSize = 5
        let batches = stride(from: 0, to: urls.count, by: batchSize).map {
            Array(urls[$0..<min($0 + batchSize, urls.count)])
        }

        var allCharacters: [CharacterModel] = []

        // Itera sobre los batches de manera secuencial
        for batch in batches {
            let characters = try await self.repository.getCharacters(from: batch)
            allCharacters.append(contentsOf: characters)
        }

        return allCharacters.sorted { $0.id < $1.id }
    }
}
