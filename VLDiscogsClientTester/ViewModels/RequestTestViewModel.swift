//
//  RequestTestViewModel.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import Foundation
internal import Combine
import VLDiscogsClient
internal import VLNetworkingClient

class RequestTestViewModel: ObservableObject {
    let discogsClient: VLDiscogsClient
    let requestTemplate: RequestUrlTemplate
    let username: String

    @Published var parameterValues: [String: String] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var response: Data = .init()
    @Published var statusCode: Int?

    private static let baseURL = "https://api.discogs.com"

    init(discogsClient: VLDiscogsClient, requestTemplate: RequestUrlTemplate, username: String) {
        self.discogsClient = discogsClient
        self.requestTemplate = requestTemplate
        self.username = username
    }

    // MARK: - Validation

    var missingRequiredFields: [RequestParameter] {
        requestTemplate.parameters.filter { param in
            guard param.isRequired, param.autoFillKey == nil else { return false }
            let value = parameterValues[param.id] ?? ""
            return value.isEmpty
        }
    }

    var isValid: Bool {
        missingRequiredFields.isEmpty
    }

    // MARK: - Auto-fill values

    var autoFillValues: [RequestParameter.AutoFillKey: String] {
        [.username: username]
    }

    // MARK: - URL building

    func buildResolvedUrl() -> URL? {
        let resolvedPath = requestTemplate.resolvedPath(values: parameterValues, autoFillValues: autoFillValues)
        let urlString = Self.baseURL + resolvedPath

        guard var components = URLComponents(string: urlString) else { return nil }

        let queryItems = requestTemplate.queryItems(from: parameterValues)
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url
    }

    // MARK: - Request execution

    @MainActor
    func sendRequest() async {
        guard isValid else { return }

        isLoading = true
        errorMessage = nil
        response = .init()
        statusCode = nil

        defer { isLoading = false }

        do {
            let resolvedPath = requestTemplate.resolvedPath(values: parameterValues, autoFillValues: autoFillValues)
            let queryItems = requestTemplate.queryItems(from: parameterValues)
            let body = requestTemplate.bodyDictionary(from: parameterValues)
            let response = try await discogsClient.request(
                method: requestTemplate.httpMethod.rawValue,
                path: resolvedPath,
                queryParameters: queryItems,
                body: body.isEmpty ? nil : body
            )
            self.response = response.data ?? Data()
            self.statusCode = response.statusCode

        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
