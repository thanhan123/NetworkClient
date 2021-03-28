//
//  CombineNetworkingClient.swift
//  NetworkClient
//
//  Created by Dinh Thanh An on 4/18/20.
//  Copyright © 2020 Dinh Thanh An. All rights reserved.
//

import Foundation
import Combine
import AnyCodable

public final class CombineNetworkingClient {
    private let session = URLSession.shared
    
    public init() {}
    
    public func performRequest(url: URL,
                               parameters: [String: AnyCodable],
                               requestType: RequestType,
                               token: String? = nil) -> AnyPublisher<Data, Error> {
        guard let request = buildRequest(url: url, parameters: parameters, requestType: requestType, token: token) else {
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
                        return NetworkError.noInternet
                    }
                case let networkError as NetworkError:
                    return networkError
                default:
                    break
                }
                return NetworkError.noData
            }
            .eraseToAnyPublisher()
    }
    
    private func buildRequest(url: URL,
                              parameters: [String: AnyCodable],
                              requestType: RequestType,
                              token: String?) -> URLRequest? {
        var request = URLRequest(url: url)
        switch requestType {
        case .get:
            guard var components = URLComponents(string: url.absoluteString) else {
                return nil
            }
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: "\(value)")
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            guard let url = components.url else {
                return nil
            }
            request = URLRequest(url: url)
            request.allHTTPHeaderFields = ["Content-Type":"application/json; charset=utf-8"]
        case .post:
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(parameters)
            request.allHTTPHeaderFields = ["Content-Type":"application/json; charset=utf-8"]
        case let .postBody(fileData, fieldName, fileName, mimeType):
            request.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = createBodyDataRequest(
                fileData: fileData,
                boundary: boundary,
                fieldName: fieldName,
                fileName: fileName,
                mimeType: mimeType
            )
        case .delete:
            request.httpMethod = "DELETE"
            request.httpBody = try? JSONEncoder().encode(parameters)
            request.allHTTPHeaderFields = ["Content-Type":"application/json; charset=utf-8"]
        case .put:
            request.httpMethod = "PUT"
            request.httpBody = try? JSONEncoder().encode(parameters)
            request.allHTTPHeaderFields = ["Content-Type":"application/json; charset=utf-8"]
        }
        
        if let token = token {
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func createBodyDataRequest(fileData: Data,
                                       boundary: String,
                                       fieldName: String,
                                       fileName: String,
                                       mimeType: String) -> Data {
        let httpBody = NSMutableData()
        httpBody.append(convertFileData(fieldName: fieldName,
                                        fileName: fileName,
                                        mimeType: mimeType,
                                        fileData: fileData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")
        return httpBody as Data
    }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
