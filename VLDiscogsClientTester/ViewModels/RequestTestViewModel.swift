//
//  RequestTestViewModel.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import Foundation
internal import Combine
import VLDiscogsClient
import VLNetworkingClient

class RequestTestViewModel: ObservableObject {
    let discogsClient: VLDiscogsClient
    let title: String
    var requestConfiguration: RequestConfiguration? {
        didSet {
            if let url = requestConfiguration?.url {
                self.url = url
            }
        }
    }
    @Published var url: URL?
    @Published var response: Data = .init()
    @Published var statusCode: String = ""
    
    init(discogsClient: VLDiscogsClient, title: String) {
        self.discogsClient = discogsClient
        self.title = title
    }
    
    func setResponse(with data: Data) {
        self.response = data
    }
    
    func getUrl() async throws {
        self.requestConfiguration = try await discogsClient.userCollectionApi.folderRequest()
    }
    
    func getResponse() async throws {
        if let requestConfiguration {
            let response: NetworkResponse<Data> = try await discogsClient.userCollectionApi.response(for: requestConfiguration)
            if let data = response.data {
                self.response = data
            }
            self.statusCode = response.statusCode.description
        }
    }
}
