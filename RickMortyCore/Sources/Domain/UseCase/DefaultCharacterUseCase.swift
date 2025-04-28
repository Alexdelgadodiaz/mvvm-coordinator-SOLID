//
//  DefaultCharacterUseCase.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//
import RickMortyModels

public final class DefaultCharacterUseCase: CharacterUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    public init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    public func getCharacters(page: Int, filter: String?) async throws -> PaginatedCharacters {
        return try await repository.getCharacters(page: page, filter: filter)
    }

    public func getEpisodes(from urls: [String]) async throws -> [EpisodeModel] {
    
        let batchSize = 5
        let batches = stride(from: 0, to: urls.count, by: batchSize).map {
            Array(urls[$0..<min($0 + batchSize, urls.count)])
        }

        var allEpisodes: [EpisodeModel] = []

        // Itera sobre los batches de manera secuencial
        for batch in batches {
            let episodes = try await self.repository.getEpisodes(from: batch)
            allEpisodes.append(contentsOf: episodes)
        }

        return allEpisodes.sorted { $0.id < $1.id }
    }
}
