//
//  CharacterModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import Foundation

package struct CharactersResponse: Decodable {
    package let info: Info
    package let results: [CharacterAPIModel]
}

package struct Info: Decodable {
    package let next: String?
}

public struct CharacterAPIModel: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let image: String
    public let status: String
    public let species: String
    public let gender: String
    public let origin: OriginAPIModel?
    public let location: LocationAPIModel?
    public let episode: [String]
    
    public init(id: Int, name: String, image: String, status: String, species: String, gender: String, origin: OriginAPIModel?, location: LocationAPIModel?, episode: [String]) {
        self.id = id
        self.name = name
        self.image = image
        self.status = status
        self.species = species
        self.gender = gender
        self.origin = origin
        self.location = location
        self.episode = episode
    }
}

public struct OriginAPIModel: Decodable, Hashable, Sendable {
    public let name: String
}

public struct LocationAPIModel: Decodable, Hashable, Sendable {
    public let name: String
}



