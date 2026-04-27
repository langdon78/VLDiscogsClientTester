//
//  ParameterFormView.swift
//  VLDiscogsClientTester
//

import SwiftUI

struct ParameterFormView: View {
    let parameters: [RequestParameter]
    let autoFillValues: [RequestParameter.AutoFillKey: String]
    @Binding var values: [String: String]

    var body: some View {
        let grouped = Dictionary(grouping: parameters) { $0.location }

        if let pathParams = grouped[.path], !pathParams.isEmpty {
            Section("Path Parameters") {
                ForEach(pathParams) { param in
                    parameterField(for: param)
                }
            }
        }

        if let queryParams = grouped[.query], !queryParams.isEmpty {
            Section("Query Parameters") {
                ForEach(queryParams) { param in
                    parameterField(for: param)
                }
            }
        }

        if let bodyParams = grouped[.body], !bodyParams.isEmpty {
            Section("Body Parameters") {
                ForEach(bodyParams) { param in
                    parameterField(for: param)
                }
            }
        }
    }

    @ViewBuilder
    private func parameterField(for param: RequestParameter) -> some View {
        if let autoFillKey = param.autoFillKey, let autoValue = autoFillValues[autoFillKey] {
            LabeledContent {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                    Text(autoValue)
                        .foregroundStyle(.secondary)
                }
            } label: {
                Text(param.name)
            }
        } else {
            switch param.valueType {
            case .enumeration(let options):
                HStack {
                    fieldLabel(for: param)
                    Spacer()
                    Picker(param.name, selection: binding(for: param.id)) {
                        Text("None").tag("")
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }

            case .intRange(let range):
                HStack {
                    fieldLabel(for: param)
                    Spacer()
                    Picker(param.name, selection: binding(for: param.id)) {
                        Text("None").tag("")
                        ForEach(Array(range), id: \.self) { value in
                            Text("\(value)").tag(String(value))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }

            case .int:
                HStack {
                    fieldLabel(for: param)
                    TextField(param.name, text: binding(for: param.id))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }

            case .string:
                HStack {
                    fieldLabel(for: param)
                    TextField(param.name, text: binding(for: param.id))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldLabel(for param: RequestParameter) -> some View {
        HStack(spacing: 2) {
            Text(param.name)
            if param.isRequired {
                Text("*")
                    .foregroundStyle(.red)
            }
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { values[key] ?? "" },
            set: { values[key] = $0 }
        )
    }
}

#Preview {
    @Previewable @State var values: [String: String] = [:]
    Form {
        ParameterFormView(
            parameters: [
                RequestParameter(id: "1", name: "Test", location: .body, valueType: .string),
                RequestParameter(id: "2", name: "Page", location: .query, valueType: .int, isRequired: false),
                RequestParameter(id: "3", name: "Sort", location: .query, valueType: .enumeration(["asc", "desc"]), isRequired: false)
            ], autoFillValues: [.username: "test_user"],
            values: $values
        )
    }
}
