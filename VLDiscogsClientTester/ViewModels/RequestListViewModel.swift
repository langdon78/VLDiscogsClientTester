//
//  RequestListViewModel.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import OrderedCollections
import VLDiscogsClient

class RequestListViewModel {
    var discogsClient: VLDiscogsClient
    var title: String
    var username: String
    let requests: OrderedDictionary<RequestSection, [RequestUrlTemplate]>

    init(discogsClient: VLDiscogsClient, title: String, username: String, requests: OrderedDictionary<RequestSection, [RequestUrlTemplate]>) {
        self.discogsClient = discogsClient
        self.title = title
        self.username = username
        self.requests = requests
    }
}
