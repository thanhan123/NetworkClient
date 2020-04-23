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
            .tryMap{ data, response in
                if let httpResponse = response as? HTTPURLResponse,
                    !(200 ... 299 ~= httpResponse.statusCode) {
                    throw NetworkError.otherError(object: data)
                }
                return data
        }
        .mapError{ error in
            switch error {
            case let urlError as URLError:
                if urlError.code == .notConnectedToInternet {
                    return .noInternet
                }
            case let networkError as NetworkError:
                return networkError
            default:
                break
            }
            return .noData
        }
        .eraseToAnyPublisher()
    }

    private func buildRequest(url: URL,
                              parameters: [String: String],
                              requestType: RequestType) -> URLRequest? {
        let updatedURL: URL
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
            updatedURL = url
        default:
            updatedURL = url
        }

        return URLRequest(url: updatedURL)
    }
}
