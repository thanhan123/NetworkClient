//
//  RequestType.swift
//  NetworkClient
//
//  Created by Dinh Thanh An on 4/18/20.
//  Copyright © 2020 Dinh Thanh An. All rights reserved.
//

import Foundation

public enum RequestType {
    case get
    case post
    case put
    case delete
    case postBody(fileData: Data,
                  fieldName: String,
                  fileName: String,
                  mimeType: String)
}
