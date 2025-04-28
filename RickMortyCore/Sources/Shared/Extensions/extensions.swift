//
//  extensions.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import Foundation
import CryptoKit

extension String {
    package func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
