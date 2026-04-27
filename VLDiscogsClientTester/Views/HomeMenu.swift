//
//  HomeMenu.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/3/25.
//

import SwiftUI
import OrderedCollections
import VLDiscogsClient

struct HomeMenu: View {
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

    private var activeUsername: String {
        guard let activeId = accountManager.activeAccount,
              let account = accountManager.accounts.first(where: { $0.identifier == activeId }) else {
            return ""
        }
        return account.userIdentity.username
    }

    var body: some View {
        NavigationStack {
            List(menuItems, id: \.self) { item in
                NavigationLink(value: item) {
                    Text("\(item)")
                }
            }
            .navigationTitle("Discogs API Tester")
            .navigationDestination(for: String.self) { item in
                NavigationDestinationView(
                    accountManager: accountManager,
                    item: item,
                    username: activeUsername
                )
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

    static func requestsForItem(_ item: String) -> OrderedDictionary<RequestSection, [RequestUrlTemplate]>? {
        switch item {
        case "Database":
            return Requests.database
        case "Marketplace":
            return Requests.marketplace
        case "User Collection":
            return Requests.userCollection
        default:
            return nil
        }
    }
}

// Helper view to handle async client loading
private struct NavigationDestinationView: View {
    @ObservedObject var accountManager: AccountManager
    let item: String
    let username: String
    @State private var client: VLDiscogsClient?

    var body: some View {
        Group {
            if let requests = HomeMenu.requestsForItem(item) {
                if let client {
                    RequestListView(viewModel: .init(
                        discogsClient: client,
                        title: item,
                        username: username,
                        requests: requests
                    ))
                } else {
                    ProgressView("Loading...")
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Coming soon")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .navigationTitle(item)
            }
        }
        .task(id: accountManager.activeAccount) {
            client = await accountManager.activeClient
        }
    }
}

#Preview {
//    HomeMenu()
}
