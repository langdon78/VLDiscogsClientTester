//
//  Endpoints.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import OrderedCollections

struct Requests {
    static let userCollection: OrderedDictionary<RequestSection, [RequestUrlTemplate]> = [
        .init(id: 1, name: "Collection"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/folders"),
            .init(id: 2, httpMethod: .post, path: "/users/{username}/collection/folders")
        ],
        .init(id: 2, name: "Collection Folders"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}"),
            .init(id: 2, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}"),
            .init(id: 3, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}")
        ],
        .init(id: 3, name: "Collection Items By Release"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/releases/{release_id}")
        ],
        .init(id: 4, name: "Collection Items By Folder"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/folders/{folder_id}/releases")
        ],
        .init(id: 5, name: "Add To Collection Folder"): [
            .init(id: 1, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}")
        ],
        .init(id: 6, name: "Change Rating of Release"): [
            .init(id: 1, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}")
        ],
        .init(id: 7, name: "Delete Instance From Folder"): [
            .init(id: 1, httpMethod: .delete, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}")
        ],
        .init(id: 8, name: "List Custom Fields"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/fields")
        ],
        .init(id: 9, name: "Edit Fields Instance"): [
            .init(id: 1, httpMethod: .post, path: "/users/{username}/collection/folders/{folder_id}/releases/{release_id}/instances/{instance_id}/fields/{field_id}{?value}")
        ],
        .init(id: 10, name: "Collection Value"): [
            .init(id: 1, httpMethod: .get, path: "/users/{username}/collection/value")
        ]
    ]
}
