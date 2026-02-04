//
//  VLDiscogsClientTester.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 8/16/25.
//

import SwiftUI
import VLDiscogsClient

@main
struct VLDiscogsClientTester: App {
    static let deepLinkCallback = OAuthDeepLinkCallbackUrl(
        scheme: "oauth-tester",
        host: "discogs"
    )
    
    @StateObject private var accountManager = AccountManager(
        callbackUrl: deepLinkCallback.url
    )
    
    var body: some Scene {
        WindowGroup {
            AccountView(accountManager: accountManager)
        }
    }
}

struct AccountView: View {
    @ObservedObject var accountManager: AccountManager
    @State private var discogsClient: VLDiscogsClient?
    
    var body: some View {
        Group {
            if discogsClient != nil {
                HomeMenu(
                    accountManager: accountManager
                )
            } else if accountManager.activeAccount != nil {
                ProgressView("Loading client...")
                    .task {
                        discogsClient = await accountManager.activeClient
                    }
            } else {
                WelcomeView(accountManager: accountManager)
            }
        }
        .onChange(of: accountManager.activeAccount) { _, newAccount in
            // Reload client when active account changes
            Task {
                if newAccount != nil {
                    discogsClient = await accountManager.activeClient
                } else {
                    discogsClient = nil
                }
            }
        }
    }
}
struct WelcomeView: View {
    @ObservedObject var accountManager: AccountManager
    @State private var isAddingAccount = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Welcome to Discogs API Tester")
                .font(.title)
                .bold()
            
            Text("Add a Discogs account to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                isAddingAccount = true
            } label: {
                Text("Add Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $isAddingAccount) {
            AddAccountView(accountManager: accountManager, isPresented: $isAddingAccount)
        }
    }
}

