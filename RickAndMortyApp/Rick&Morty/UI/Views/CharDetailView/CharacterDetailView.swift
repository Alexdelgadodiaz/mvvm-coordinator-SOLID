//
//  CharacterDetailView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//
import SwiftUI
import RickMortyModels
import RickMortyShared


struct CharacterDetailView: View {
    @StateObject var viewModel: CharacterDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Sección de imagen del personaje
                CharacterHeaderView(character: viewModel.character)
                
                // Sección de información básica
                CharacterInfoView(character: viewModel.character)
                
                // Sección de episodios
                EpisodesListInCharView(episodes: viewModel.episodes,
                               isLoading: viewModel.isLoading,
                               errorMessage: viewModel.errorMessage)
            }
            .padding()
        }
        .navigationTitle(viewModel.character.name)
        .task {
            if viewModel.episodes.isEmpty {
                await viewModel.fetchEpisodes()
            }
        }
        .refreshable {
            await viewModel.fetchEpisodes()
        }
    }
}

// MARK: - Subviews

struct CharacterHeaderView: View {
    let character: CharacterModel

    var body: some View {
        VStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: character.image)!) { image in
                image
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 6)

//            Text(character.name)
//                .font(.largeTitle)
//                .bold()
//                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }
}

struct CharacterInfoView: View {
    let character: CharacterModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(label: "status", value: character.status, icon: "heart.fill")
            InfoRow(label: "species", value: character.species, icon: "pawprint.fill")
            InfoRow(label: "gender", value: character.gender, icon: "person.fill")

            if let origin = character.origin?.name {
                InfoRow(label: "origin", value: origin, icon: "globe")
            }

            if let location = character.location?.name {
                InfoRow(label: "location", value: location, icon: "mappin.and.ellipse")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(LocalizedStringKey(label), systemImage: icon)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .bold()
            Spacer()
        }
    }
}

struct EpisodesListInCharView: View {
    let episodes: [EpisodeModel]
    let isLoading: Bool
    let errorMessage: String?
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("appears_in"))
                .font(.title2.bold())
                .padding(.top)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = errorMessage {
                ErrorView(error: error)
            } else if episodes.isEmpty {
                Text(LocalizedStringKey("no_episodes_found"))
                    .foregroundColor(.secondary)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(episodes) { episode in
                        Button(action: {
                            coordinator.showEpisodeDetailFromAnywhere(episode)
                        }) {
                            EpisodeInCharRow(episode: episode)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct EpisodeInCharRow: View {
    let episode: EpisodeModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.name)
                    .font(.body)
                    .foregroundColor(.primary)

                Text("\(episode.episode) • \(localizedDate(from: episode.air_date))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
