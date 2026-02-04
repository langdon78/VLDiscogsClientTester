//
//  RequestSection.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

struct RequestSection: Identifiable, Hashable, Equatable, Comparable {
    var id: Int
    var name: String
    
    static func < (lhs: RequestSection, rhs: RequestSection) -> Bool {
        lhs.id < rhs.id
    }
}
