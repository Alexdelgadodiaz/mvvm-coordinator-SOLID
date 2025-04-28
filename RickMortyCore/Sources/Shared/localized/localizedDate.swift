//
//  localizedDate.swift
//  RickMortyCore
//
//  Created by AlexDelgado on 28/4/25.
//
import Foundation

public func localizedDate(from string: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "MMMM d, yyyy" 
    inputFormatter.locale = Locale(identifier: "en_US_POSIX") 

    guard let date = inputFormatter.date(from: string) else {
        return string 
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .long
    outputFormatter.timeStyle = .none
    outputFormatter.locale = Locale.current 
    
    return outputFormatter.string(from: date)
}
