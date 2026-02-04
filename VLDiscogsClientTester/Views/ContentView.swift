//
//  ContentView.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 8/16/25.
//

import SwiftUI
import VLDiscogsClient

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button("Folders 📁") {
                    Task { @MainActor in
                        do {
                            try await viewModel.getFolders()
                        } catch {
                            print(error)
                        }
                    }
                }
                Spacer()
            }
            NavigationStack {
                List(viewModel.folders, id: \.id) { item in
                    NavigationLink(value: item) {
                        Text("\(item.name) - \(item.count)")
                    }
                }.navigationDestination(for: CollectionFolder.self) { folder in
                    DetailView(discogsClient: viewModel.discogsClient, folderId: folder.id)
                }
            }
        }
        .padding()
        .task {
            do {
                try await viewModel.start()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}


struct DetailView: View {
    @State var records: [String] = []
    var discogsClient: VLDiscogsClient?
    var folderId: Int
    
    var body: some View {
        List(records, id: \.self) { item in
            Text(item)
        }.task {
            do {
                guard let discogsClient else { return }
                records = try await discogsClient.userCollectionApi.collectionItemsByFolder(
                    folderId: folderId,
                    sort: .artist,
                    sortOrder: .asc
                ).releases
                .map { "\($0.basic_information.artists.first?.name ?? "Unknown") - \($0.basic_information.title)" }
            } catch {
                print(error)
            }
        }
    }
}
