//
//  HttpMethod.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import SwiftUI

struct RequestUrlTemplate: Identifiable, Hashable {
    var id: Int

    enum Action {
        case request
        case downloadFile
    }

    enum HttpMethod: String {
        case get
        case post
        case put
        case delete

        var description: String {
            rawValue.uppercased()
        }

        var color: Color {
            switch self {
            case .get: return .blue
            case .post: return .green
            case .put: return .gray
            case .delete: return .red
            }
        }
    }
    var httpMethod: HttpMethod
    var path: String
    var parameters: [RequestParameter]
    var action: Action

    init(id: Int, httpMethod: HttpMethod, path: String, parameters: [RequestParameter] = [], action: Action = .request) {
        self.id = id
        self.httpMethod = httpMethod
        self.path = path
        self.parameters = parameters
        self.action = action
    }

    // MARK: - Filtered parameter accessors

    var pathParameters: [RequestParameter] {
        parameters.filter { $0.location == .path }
    }

    var userPathParameters: [RequestParameter] {
        pathParameters.filter { $0.autoFillKey == nil }
    }

    var queryParameters: [RequestParameter] {
        parameters.filter { $0.location == .query }
    }

    var bodyParameters: [RequestParameter] {
        parameters.filter { $0.location == .body }
    }

    // MARK: - URL resolution

    func resolvedPath(values: [String: String], autoFillValues: [RequestParameter.AutoFillKey: String]) -> String {
        var result = path

        // Strip RFC 6570 query syntax like {?value}
        if let queryRange = result.range(of: #"\{\?[^}]+\}"#, options: .regularExpression) {
            result.removeSubrange(queryRange)
        }

        // Substitute path parameters
        for param in pathParameters {
            let placeholder = "{\(param.id)}"
            if let autoFillKey = param.autoFillKey, let autoValue = autoFillValues[autoFillKey] {
                result = result.replacingOccurrences(of: placeholder, with: autoValue)
            } else if let value = values[param.id], !value.isEmpty {
                result = result.replacingOccurrences(of: placeholder, with: value)
            }
        }

        return result
    }

    func queryItems(from values: [String: String]) -> [URLQueryItem] {
        queryParameters.compactMap { param in
            guard let value = values[param.id], !value.isEmpty else { return nil }
            return URLQueryItem(name: param.id, value: value)
        }
    }

    func bodyDictionary(from values: [String: String]) -> [String: Any] {
        var dict: [String: Any] = [:]
        for param in bodyParameters {
            guard let value = values[param.id], !value.isEmpty else { continue }
            switch param.valueType {
            case .int, .intRange:
                dict[param.id] = Int(value) ?? value
            default:
                dict[param.id] = value
            }
        }
        return dict
    }
}
