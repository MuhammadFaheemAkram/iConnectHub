//
//  BundleJSON.swift
//  ConnectHub
//
//  Created by BitFuse on 24/07/2026.
//

import Foundation

/// Loads and decodes JSON bundled with the app. The fake service layer uses
/// this to serve hard-coded responses from resource files, mirroring how a real
/// client would decode a network payload.
enum BundleJSON {
    static func decode<T: Decodable>(
        _ type: T.Type,
        from resource: String,
        bundle: Bundle = .main,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw AppError.notFound
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decoding
        }
    }
}
