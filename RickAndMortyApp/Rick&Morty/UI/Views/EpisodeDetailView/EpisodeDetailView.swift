//
//  EpisodeDetailView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import SwiftUI
import RickMortyModels

struct EpisodeDetailView: View {
    @StateObject var viewModel: EpisodeDetailViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                episodeHeader
                characterListSection
            }
            .padding()
        }
        .task {
            if viewModel.characters.isEmpty {
                await viewModel.fetchCharacters(for: viewModel.episode.characters)
            }
        }
        .navigationTitle(viewModel.episode.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var episodeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Emitido el \(viewModel.episode.air_date)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Código: \(viewModel.episode.episode)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 12)
    }

    private var characterListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personajes")
                .font(.headline)
                .foregroundColor(.primary)

            if viewModel.isLoadingCharacters {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            } else if viewModel.characters.isEmpty {
                Text("No hay personajes disponibles.")
                    .foregroundColor(.gray)
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                    spacing: 16
                ) {
                    ForEach(viewModel.characters, id: \.id) { character in
                        CharacterCard(character: character)
                            .onTapGesture {
                                coordinator.showCharacterDetailFromAnywhere(character)
                            }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct CharacterCard: View {
    let character: CharacterModel

    var body: some View {
        VStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: character.image)!) { image in
                image
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .shadow(radius: 3)

            Text(character.name)
                .font(.caption)
                .frame(width: 80)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
    }
}
