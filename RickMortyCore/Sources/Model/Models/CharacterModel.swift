//
//  CharacterModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import Foundation

public struct CharacterModel: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let image: String
    public let status: String
    public let species: String
    public let gender: String
    public let origin: OriginModel?
    public let location: LocationModel?
    public let episode: [String]

    public init(apiModel: CharacterAPIModel) {
        self.id = String(apiModel.id)
        self.name = apiModel.name
        self.image = apiModel.image
        self.status = apiModel.status
        self.species = apiModel.species
        self.gender = apiModel.gender
        self.origin = apiModel.origin.map { OriginModel(name: $0.name) }
        self.location = apiModel.location.map { LocationModel(name: $0.name) }
        self.episode = apiModel.episode
    }
}

public struct PaginatedCharacters: Codable, Sendable {
    public let characters: [CharacterModel]
    public let hasNextPage: Bool

    public init(characters: [CharacterModel], hasNextPage: Bool) {
        self.characters = characters
        self.hasNextPage = hasNextPage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.characters = try container.decode([CharacterModel].self, forKey: .characters)
        self.hasNextPage = try container.decode(Bool.self, forKey: .hasNextPage)
    }

    private enum CodingKeys: String, CodingKey {
        case characters
        case hasNextPage
    }
}

public struct OriginModel: Hashable, Codable, Sendable {
    public let name: String
}

public struct LocationModel: Hashable, Codable, Sendable {
    public let name: String
}
