//
//  Secrets.swift
//  VLDiscogsClientTester
//
//  Reads Discogs API credentials that are injected at build time from
//  Config/Secrets.xcconfig into Info.plist. See Config/Secrets.xcconfig.template
//  for setup instructions.
//

import Foundation

/// Build-time secrets injected via Config/Secrets.xcconfig and Info.plist.
enum Secrets {
    /// The Discogs consumer key for this application.
    static let discogsConsumerKey = value(for: "DiscogsConsumerKey")

    /// The Discogs consumer secret for this application.
    static let discogsConsumerSecret = value(for: "DiscogsConsumerSecret")

    /// Reads a non-empty string from the app's Info.plist, trapping with a
    /// helpful message when the value is missing — which almost always means
    /// Config/Secrets.xcconfig hasn't been created from the template.
    private static func value(for key: String) -> String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty
        else {
            fatalError(
                """
                Missing Info.plist value for "\(key)". \
                Copy Config/Secrets.xcconfig.template to Config/Secrets.xcconfig \
                and fill in your Discogs credentials.
                """
            )
        }
        return value
    }
}
