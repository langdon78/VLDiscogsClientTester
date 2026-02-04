//
//  HomeMenu.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/3/25.
//

import SwiftUI
import VLDiscogsClient

struct HomeMenu: View {
//    @State var discogsClient: VLDiscogsClient
    @ObservedObject var accountManager: AccountManager
    @State var isVisible = false
    let menuItems: [String] = [
        "Authentication",
        "Database",
        "Marketplace",
        "Inventory Export",
        "Inventory Import",
        "User Identity",
        "User Collection",
        "User Wantlist",
        "User Lists"
    ]
    
    var body: some View {
        NavigationStack {
            List(menuItems, id: \.self) { item in
                NavigationLink(value: item) {
                    Text("\(item)")
                }
            }
            .navigationTitle("Discogs API Tester")
            .navigationDestination(for: String.self) { item in
                NavigationDestinationView(accountManager: accountManager, item: item)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AccountSwitcherView(accountManager: accountManager)
                    } label: {
                        Label("Accounts", systemImage: "person.2.fill")
                    }
                }
            }
        }
    }
}

// Helper view to handle async client loading
private struct NavigationDestinationView: View {
    @ObservedObject var accountManager: AccountManager
    let item: String
    @State private var client: VLDiscogsClient?
    
    var body: some View {
        Group {
            if let client {
                RequestListView(viewModel: .init(discogsClient: client, title: item, requests: Requests.userCollection))
            } else {
                ProgressView("Loading...")
            }
        }
        .task(id: accountManager.activeAccount) {
            // Reload client whenever the active account changes
            client = await accountManager.activeClient
        }
    }
}

#Preview {
//    HomeMenu()
}
