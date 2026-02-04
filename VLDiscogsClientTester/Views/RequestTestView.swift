//
//  RequestTestView.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import SwiftUI
import VLDiscogsClient

struct RequestTestView: View {
    @StateObject var viewModel: RequestTestViewModel
    
    var body: some View {
        ScrollView {
        VStack(alignment: .leading) {
            Text("Request")
                .font(.title)
            Text(viewModel.url?.absoluteString ?? "")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1)
                )
            HStack {
                Spacer()
                Button("Send") {
                    Task {
                        try await viewModel.getResponse()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            Spacer()
            HStack {
                Text("Response")
                    .font(.title)
                if !viewModel.statusCode.isEmpty {
                    Text("\(viewModel.statusCode)")
                        .font(.caption.bold())
                        .padding(6)
                        .background(.green)
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
            }
            Text(getJson(from: viewModel.response))
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .navigationTitle(viewModel.title)
        .task {
            do {
                try await viewModel.getUrl()
            } catch {
                print(error)
            }
        }
    }
    
    private func getJson(from data: Data) -> String {
        guard !data.isEmpty else { return "" }
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return "Invalid JSON"
        }
        return prettyString
    }
}

#Preview {
//    let jsonString = #"""
//    {
//        "id": 37,
//        "name": "John Doe",
//        "isActive": true,
//        "metadata": {
//            "role": "iOS Developer"
//        },
//        "shitter": true
//    }
//    """#
//
//    let viewModel = RequestTestViewModel(discogsClient: VLDiscogsClient(), title: "Collection", url: URL(string: "https://api.discogs.com/users/vlclienttester/collections/folders")!)
//    viewModel.response = jsonString.data(using: .utf8)!
//
//    return NavigationStack {
//        RequestTestView(viewModel: viewModel)
//    }
}
