//
//  NoConnectionView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 29/4/25.
//
import SwiftUI

struct NoConnectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.red)
            Text(NSLocalizedString("no_connection_title", comment: "Título mostrado cuando no hay conexión a internet"))
                .font(.title2)
                .multilineTextAlignment(.center)
            Text(NSLocalizedString("no_connection_description", comment: "Descripción mostrada cuando no hay conexión a internet"))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
