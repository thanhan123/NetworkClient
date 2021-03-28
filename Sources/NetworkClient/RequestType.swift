//
//  RequestType.swift
//  NetworkClient
//
//  Created by Dinh Thanh An on 4/18/20.
//  Copyright © 2020 Dinh Thanh An. All rights reserved.
//

import Foundation
import AnyCodable

public enum RequestType {
    case get(parameters: [String: AnyCodable] = [:])
    case post(parameters: [String: AnyCodable] = [:])
    case put(parameters: [String: AnyCodable] = [:])
    case delete(parameters: [String: AnyCodable] = [:])
    case postBody(data: PostBodyData)
}

public struct PostBodyData {
    let fileData: Data
    let fieldName: String
    let fileName: String
    let mimeType: String
    
    public init(
        fileData: Data,
        fileName: String,
        fieldName: String,
        mimeType: String
    ) {
        self.fileData = fileData
        self.fileName = fileName
        self.fieldName = fieldName
        self.mimeType = mimeType
    }
}
