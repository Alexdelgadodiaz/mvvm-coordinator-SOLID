//
//  CharacterRepositoryProtocol.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import RickMortyModels

public protocol CharacterRepositoryProtocol {
    func getCharacters(page: Int, filter: String?) async throws -> PaginatedCharacters
    func getEpisodes(from urls: [String]) async throws -> [EpisodeModel]
}
