//
//  CacheEntry.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import Foundation

public final class CacheEntry<T: Codable>: NSObject, Codable {
    public let value: T
    public let expirationDate: Date

    public init(value: T, expiration: TimeInterval) {
        self.value = value
        self.expirationDate = Date().addingTimeInterval(expiration)
    }

    public var isExpired: Bool {
        return Date() > expirationDate
    }
}
