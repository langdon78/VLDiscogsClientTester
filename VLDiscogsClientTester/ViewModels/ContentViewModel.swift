//
//  ContentViewModel.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/3/25.
//

import Foundation
internal import Combine
import VLDiscogsClient

final class ContentViewModel: ObservableObject {
    static let deepLinkCallback = OAuthDeepLinkCallbackUrl(
        scheme: "oauth-tester",
        host: "discogs"
    )
    @Published var folders: [CollectionFolder] = []

    var discogsClient: VLDiscogsClient?

    func start() async throws {
        self.discogsClient = try await VLDiscogsClient(deepLinkCallback: Self.deepLinkCallback)
    }
    
    func getFolders() async throws {
        guard let discogsClient else { return }
        folders = try await discogsClient.userCollectionApi.collectionFolders().folders
    }
    
    func clearUserTokens() async throws {
        try await discogsClient?.clearTokens()
    }
}
