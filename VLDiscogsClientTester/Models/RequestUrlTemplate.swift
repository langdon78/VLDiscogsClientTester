//
//  HttpMethod.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import SwiftUI

struct RequestUrlTemplate: Identifiable, Hashable {
    var id: Int
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
}
