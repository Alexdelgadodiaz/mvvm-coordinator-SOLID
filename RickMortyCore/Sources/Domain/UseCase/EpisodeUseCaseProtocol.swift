//
//  EpisodeUseCaseProtocol.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import RickMortyModels

public protocol EpisodeUseCaseProtocol {
    func getEpisodes(page: Int, filter: String?) async throws -> PaginatedEpisodes
    func getCharacters(from urls: [String]) async throws -> [CharacterModel]
}
