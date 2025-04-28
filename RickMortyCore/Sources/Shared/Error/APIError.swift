//
//  APIError.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//


package enum APIError: Error {
    case invalidURL
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case decodingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL format"
        case .invalidResponse: return "Received invalid response from server"
        case .clientError(let code): return "Client error (status code: \(code))"
        case .serverError(let code): return "Server error (status code: \(code))"
        case .unexpectedStatusCode(let code): return "Unexpected status code: \(code)"
        case .decodingFailed(let error): return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
