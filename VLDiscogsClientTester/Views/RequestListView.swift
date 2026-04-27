//
//  APIEndpointsView.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/3/25.
//

import SwiftUI
import OrderedCollections

struct RequestListView: View {
    var viewModel: RequestListViewModel

    var body: some View {
        List {
            ForEach(Array(viewModel.requests.keys.sorted())) { sectionKey in
                Section {
                    ForEach(viewModel.requests[sectionKey] ?? []) { requestTemplate in
                        NavigationLink(value: requestTemplate) {
                            requestLabel(for: requestTemplate)
                        }
                    }
                } header: {
                    Text(sectionKey.name)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationDestination(for: RequestUrlTemplate.self) { template in
            RequestTestView(
                viewModel: RequestTestViewModel(
                    discogsClient: viewModel.discogsClient,
                    requestTemplate: template,
                    username: viewModel.username
                )
            )
        }
    }

    @ViewBuilder
    private func requestLabel(for requestTemplate: RequestUrlTemplate) -> some View {
        Text("\(requestTemplate.httpMethod.description)")
            .font(.caption.bold())
            .padding(6)
            .background(requestTemplate.httpMethod.color)
            .cornerRadius(4)
            .foregroundColor(.white)
        Text(requestTemplate.path)
            .font(.callout)
            .minimumScaleFactor(0.5)
            .lineLimit(2)
    }
}

#Preview {
//    RequestListView(
//        viewModel: RequestListViewModel(title: "User Collection", requests: Requests.userCollection)
//    )
}
