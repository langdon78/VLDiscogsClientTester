//
//  RequestTestView.swift
//  VLDiscogsClientTester
//
//  Created by James Langdon on 12/4/25.
//

import SwiftUI

struct RequestTestView: View {
    @StateObject var viewModel: RequestTestViewModel
    var body: some View {
        Form {
            ParameterFormView(
                parameters: viewModel.requestTemplate.parameters,
                autoFillValues: viewModel.autoFillValues,
                values: $viewModel.parameterValues
            )

            Section("URL Preview") {
                Text(viewModel.buildResolvedUrl()?.absoluteString ?? "incomplete")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(viewModel.buildResolvedUrl() != nil ? .primary : .secondary)
                    .textSelection(.enabled)
            }

            Section {
                Button {
                    Task {
                        await viewModel.sendRequest()
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.trailing, 4)
                        }
                        Text("Send \(viewModel.requestTemplate.httpMethod.description)")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.requestTemplate.httpMethod.color)
                .disabled(!viewModel.isValid || viewModel.isLoading)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if let fileURL = viewModel.downloadedFileURL {
                Section("Downloaded File") {
                    LabeledContent("Location") {
                        Text(fileURL.lastPathComponent)
                            .font(.system(.caption, design: .monospaced))
                    }
                    ShareLink(item: fileURL) {
                        Label("Share File", systemImage: "square.and.arrow.up")
                    }
                }
            }

            if viewModel.statusCode != nil || !viewModel.response.isEmpty {
                Section {
                    HStack {
                        Text("Response")
                            .font(.headline)
                        Spacer()
                        if let code = viewModel.statusCode {
                            statusBadge(for: code)
                        }
                    }
                    TextEditor(text: .constant(prettyJson(from: viewModel.response)))
                        .font(.system(.caption2, design: .monospaced))
                        .scrollDisabled(true)
                }
            }
        }
        .navigationTitle(viewModel.requestTemplate.path)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func statusBadge(for code: Int) -> some View {
        Text("\(code)")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: code))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .foregroundStyle(.white)
    }

    private func statusColor(for code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 400..<500: return .orange
        default: return .red
        }
    }

    private func prettyJson(from data: Data) -> String {
        guard !data.isEmpty else { return "" }
        guard let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8) ?? "Invalid response"
        }
        return prettyString
    }
}

#Preview {
//    NavigationStack {
//        RequestTestView(viewModel: RequestTestViewModel(
//            discogsClient: ...,
//            requestTemplate: Requests.userCollection.values.first!.first!,
//            username: "testuser"
//        ))
//    }
}
