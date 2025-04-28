//
//  EmptyStateView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .padding(.bottom, 16)
            Text(NSLocalizedString("no_characters_found", comment: "no_characters_found"))
                .font(.title3)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
