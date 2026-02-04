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
    let requests: OrderedDictionary<RequestSection, [RequestUrlTemplate]>

    init(discogsClient: VLDiscogsClient, title: String, requests: OrderedDictionary<RequestSection, [RequestUrlTemplate]>) {
        self.discogsClient = discogsClient
        self.title = title
        self.requests = requests
    }
}
