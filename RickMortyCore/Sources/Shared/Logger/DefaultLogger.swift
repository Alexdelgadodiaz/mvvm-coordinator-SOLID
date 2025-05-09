//
//  DefaultLogger.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//


public struct DefaultLogger: LoggerProtocol {
    
    public init(){}
    
    public func logInfo(_ message: String) {
        print("ℹ️ [INFO]: \(message)")
    }

    public func logError(_ message: String) {
        print("❌ [ERROR]: \(message)")
    }
    
    public func logWarning(_ message: String) {
        print("‼️ [WARNING]: \(message)")

    }
}
