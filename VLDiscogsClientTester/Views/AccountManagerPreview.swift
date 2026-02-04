//
//  AccountManagerPreview.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/25/25.
//

import Foundation
import VLDiscogsClient

#if DEBUG
extension AccountManager {
    /// Create a mock account manager for previews and testing
    static func mock(withAccounts count: Int = 2) -> AccountManager {
        let manager = AccountManager(
            callbackUrl: URL(string: "oauth-tester://discogs")!,
            accountStore: MockAccountStore()
        )
        
        // Add mock accounts
        for i in 1...count {
            let identity = UserIdentity(
                id: 1000 + i,
                username: "testuser\(i)",
                resource_url: "https://api.discogs.com/users/testuser\(i)",
                consumer_name: "Test Consumer"
            )
            let account = StoredAccount(
                identifier: AccountIdentifier(username: identity.username),
                userIdentity: identity,
                lastActive: Date().addingTimeInterval(TimeInterval(-3600 * i))
            )
            Task { @MainActor in
                manager.accounts.append(account)
            }
        }
        
        // Set first account as active
        if count > 0 {
            Task { @MainActor in
                manager.activeAccount = manager.accounts.first?.identifier
            }
        }
        
        return manager
    }
}

/// Mock account store for testing/previews
class MockAccountStore: AccountStore {
    private var accounts: [StoredAccount] = []
    private var activeAccount: AccountIdentifier?
    
    func loadAccounts() -> [StoredAccount] {
        accounts
    }
    
    func saveAccounts(_ accounts: [StoredAccount]) {
        self.accounts = accounts
    }
    
    func loadActiveAccount() -> AccountIdentifier? {
        activeAccount
    }
    
    func saveActiveAccount(_ identifier: AccountIdentifier) {
        activeAccount = identifier
    }
    
    func clearActiveAccount() {
        activeAccount = nil
    }
}

extension UserIdentity {
    static func mock(
        id: Int = 12345,
        username: String = "mockuser",
        resourceUrl: String? = nil,
        consumerName: String = "Mock Consumer"
    ) -> UserIdentity {
        UserIdentity(
            id: id,
            username: username,
            resource_url: resourceUrl ?? "https://api.discogs.com/users/\(username)",
            consumer_name: consumerName
        )
    }
}
#endif
