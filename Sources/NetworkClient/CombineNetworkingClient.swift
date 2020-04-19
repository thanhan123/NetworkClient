//
//  CombineNetworkingClient.swift
//  NetworkClient
//
//  Created by Dinh Thanh An on 4/18/20.
//  Copyright © 2020 Dinh Thanh An. All rights reserved.
//

import Foundation
import Combine

public final class CombineNetworkingClient {
    private let session = URLSession.shared

    public init() {}

    public func performRequest(url: URL,
                               parameters: [String: String],
                               requestType: RequestType) -> AnyPublisher<Data, NetworkError> {
        guard let request = buildRequest(url: url, parameters: parameters, requestType: requestType) else {
            return Empty().eraseToAnyPublisher()
        }
        return session
            .dataTaskPublisher(for: request)
            .map(\.data)
            .mapError{ error in
                if error.code == .notConnectedToInternet {
                    return .noInternet
                }
                return .noData
        }
        .eraseToAnyPublisher()
    }

    private func buildRequest(url: URL,
                              parameters: [String: String],
                              requestType: RequestType) -> URLRequest? {
        var request: URLRequest
        switch requestType {
        case .get:
            guard var components = URLComponents(string: url.absoluteString) else {
                return nil
            }
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            guard let url = components.url else {
                return nil
            }
            request = URLRequest(url: url)

        case .post:
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        default:
            request = URLRequest(url: url)
        }

        return request
    }
}
