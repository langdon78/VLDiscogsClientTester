//
//  RequestParameter.swift
//  VLDiscogsClientTester
//

import Foundation

struct RequestParameter: Identifiable, Hashable {
    let id: String
    let name: String
    let location: Location
    let valueType: ValueType
    let isRequired: Bool
    let autoFillKey: AutoFillKey?

    enum Location: String, Hashable {
        case path
        case query
        case body
    }

    enum ValueType: Hashable {
        case string
        case int
        case intRange(ClosedRange<Int>)
        case enumeration([String])
    }

    enum AutoFillKey: String {
        case username
    }

    init(
        id: String,
        name: String,
        location: Location,
        valueType: ValueType = .string,
        isRequired: Bool = true,
        autoFillKey: AutoFillKey? = nil
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.valueType = valueType
        self.isRequired = isRequired
        self.autoFillKey = autoFillKey
    }
}
