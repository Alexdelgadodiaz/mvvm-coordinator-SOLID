//
//  CharactersListView.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import SwiftUI
import RickMortyModels

struct CharactersListView: View {
    @StateObject var viewModel: CharactersListViewModel
    @State private var isGridView = false
    @State private var fetchTask: Task<Void, Never>?

    var body: some View {
        CharacterListContent(viewModel: viewModel, isGridView: isGridView)
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic))
            .onChange(of: viewModel.searchQuery, initial: false) { oldValue, newValue in                restartFetchTask {
                    await viewModel.handleSearchChange(newQuery: newValue)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isGridView.toggle()
                    } label: {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
            .refreshable {
                await viewModel.fetchCharacters(reset: true)
            }
            .task(id: viewModel.characters) {
                if viewModel.characters.isEmpty {
                    await viewModel.fetchCharacters()
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

struct CharacterListContent: View {
    @ObservedObject var viewModel: CharactersListViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    let isGridView: Bool

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            if isGridView {
                gridView
            } else {
                listView
            }
        }
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.characters, id: \.id) { character in
                    CharacterGridItem(character: character)
                        .onTapGesture {
                            coordinator.showCharacterDetail(character)
                        }
                        .onAppear {
                            prefetchIfNeeded(for: character)
                        }
                }
            }
            .padding(.horizontal)
        }
        .refreshable {
            await viewModel.fetchCharacters(reset: true)
        }
        .overlay {
            if viewModel.characters.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            }
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.characters, id: \.id) { character in
                CharacterRow(character: character)
                    .onTapGesture {
                        coordinator.showCharacterDetail(character)
                    }
                    .onAppear {
                        prefetchIfNeeded(for: character)
                    }
            }
        }
        .listStyle(.plain)
        .padding(.horizontal)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.fetchCharacters(reset: true)
        }
        .overlay {
            if viewModel.characters.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            }
        }
    }

    @MainActor
    private func prefetchIfNeeded(for character: CharacterModel) {
        if viewModel.shouldLoadMoreData(currentItem: character) && viewModel.hasMorePages {
            Task {
                await viewModel.fetchNextPage()
            }
        }
    }
}

struct CharacterRow: View {
    let character: CharacterModel

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: character.image)!) { image in
                image
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 50, height: 50)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(radius: 3)

            Text(character.name)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

struct CharacterGridItem: View {
    let character: CharacterModel

    var body: some View {
        VStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: character.image)!) { image in
                image
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 100, height: 100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(radius: 3)

            Text(character.name)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 100)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .frame(maxHeight: .infinity)
    }
}
