//
//  AccountSwitcherView.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/25/25.
//

import SwiftUI
import VLDiscogsClient

struct AccountSwitcherView: View {
    @ObservedObject var accountManager: AccountManager
    @State private var isAddingAccount = false
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            Section("Active Account") {
                if let activeAccount = accountManager.activeAccount,
                   let account = accountManager.accounts.first(where: { $0.identifier == activeAccount }) {
                    AccountRow(account: account, isActive: true)
                } else {
                    Text("No active account")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("All Accounts") {
                ForEach(accountManager.accounts, id: \.identifier) { account in
                    AccountRow(
                        account: account,
                        isActive: account.identifier == accountManager.activeAccount
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await switchAccount(to: account.identifier)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await removeAccount(account.identifier)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            Section {
                Button {
                    isAddingAccount = true
                } label: {
                    Label("Add Account", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Accounts")
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $isAddingAccount) {
            AddAccountView(accountManager: accountManager, isPresented: $isAddingAccount)
        }
    }
    
    private func switchAccount(to identifier: AccountIdentifier) async {
        do {
            try await accountManager.switchToAccount(identifier)
        } catch {
            errorMessage = "Failed to switch accounts: \(error.localizedDescription)"
        }
    }
    
    private func removeAccount(_ identifier: AccountIdentifier) async {
        do {
            try await accountManager.removeAccount(identifier)
        } catch {
            errorMessage = "Failed to remove account: \(error.localizedDescription)"
        }
    }
}

struct AccountRow: View {
    let account: StoredAccount
    let isActive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.userIdentity.username)
                    .font(.headline)
                
                Text("ID: \(account.userIdentity.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Last active: \(account.lastActive.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}

struct AddAccountView: View {
    let accountManager: AccountManager
    @Binding var isPresented: Bool
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("Add Discogs Account")
                    .font(.title2)
                    .bold()
                
                Text("You'll be redirected to Discogs to authorize this app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isAuthenticating {
                    ProgressView("Authenticating...")
                } else {
                    Button {
                        Task {
                            await authenticateAccount()
                        }
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(isAuthenticating)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func authenticateAccount() async {
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        do {
            _ = try await accountManager.authenticateNewAccount()
            isPresented = false
        } catch {
            errorMessage = "Failed to authenticate: \(error.localizedDescription)"
        }
    }
}

#Preview("Account Switcher") {
    NavigationStack {
        AccountSwitcherView(
            accountManager: AccountManager(
                callbackUrl: URL(string: "oauth-tester://discogs")!
            )
        )
    }
}
