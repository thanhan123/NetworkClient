//
//  NetworkError.swift
//  NetworkClient
//
//  Created by Dinh Thanh An on 4/18/20.
//  Copyright © 2020 Dinh Thanh An. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case noInternet
    case noData
    case otherError(object: Any)
}
