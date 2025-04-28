//
//  EpisodesListView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//


import SwiftUI
import RickMortyModels
import RickMortyShared

struct EpisodesListView: View {
    @StateObject var viewModel: EpisodesListViewModel
    @State private var fetchTask: Task<Void, Never>?

    var body: some View {
        EpisodeListContent(viewModel: viewModel)
            .navigationTitle("episodes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic))
            .onChange(of: viewModel.searchQuery, initial: false) { _, newValue in
                restartFetchTask {
                    await viewModel.handleSearchChange(newQuery: newValue)
                }
            }
            .refreshable {
                await viewModel.fetchEpisodes(reset: true)
            }
            .task(id: viewModel.episodes) {
                if viewModel.episodes.isEmpty {
                    await viewModel.fetchEpisodes(reset: true)
                }
            }
            .onDisappear {
                fetchTask?.cancel()
            }
    }

    private func restartFetchTask(_ action: @escaping @Sendable () async -> Void) {
        fetchTask?.cancel()
        fetchTask = Task {
            await action()
        }
    }
}

struct EpisodeListContent: View {
    @ObservedObject var viewModel: EpisodesListViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            if viewModel.episodes.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            } else {
                List {
                    ForEach(viewModel.episodes, id: \.id) { episode in
                        EpisodeRowButton(episode: episode) {
                            coordinator.showEpisodeDetail(episode)
                        }
                        .onAppear {
                            prefetchIfNeeded(for: episode)
                        }
                    }

                    if viewModel.isLoading {
                        loadingIndicator
                    } else if viewModel.hasMorePages {
                        prefetchTrigger
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var loadingIndicator: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            }
        }
    }

    private var prefetchTrigger: some View {
        Section {
            Color.clear
                .frame(height: 1)
                .onAppear {
                    prefetchLastItem()
                }
        }
    }

    @MainActor
    private func prefetchIfNeeded(for episode: EpisodeModel) {
        if viewModel.shouldLoadMoreData(currentItem: episode) && viewModel.hasMorePages {
            Task {
                await viewModel.fetchNextPage()
            }
        }
    }

    @MainActor
    private func prefetchLastItem() {
        guard let lastEpisode = viewModel.episodes.last else { return }
        prefetchIfNeeded(for: lastEpisode)
    }
}

struct EpisodeRowButton: View {
    let episode: EpisodeModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            EpisodeRow(episode: episode)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("Episode_\(episode.id)")
    }
}

struct EpisodeRow: View {
    let episode: EpisodeModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(episode.name)
                .font(.headline)

            HStack {
                Text(String(format: NSLocalizedString("aired", comment: ""), localizedDate(from: episode.air_date)))
                    .font(.subheadline)

                Spacer()

                Text(episode.episode)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ErrorView: View {
    let error: String

    var body: some View {
        Text(error)
            .foregroundColor(.red)
            .padding()
    }
}
