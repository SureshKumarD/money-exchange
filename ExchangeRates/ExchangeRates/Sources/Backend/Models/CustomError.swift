//
//  File.swift
//  
//
//  Created by Suresh on 22/07/2020.
//

import Foundation
import Combine

public struct CustomError: Decodable {
    public let message: String?
    public var error: Bool?
    public let status: Int?
    public var description: String?
    
    static public func processNetworkError(error: NetworkError) -> CustomError {
        switch error {
        case let .apiError(error):
            return error
        default:
            return CustomError(message: "Unknown error", status: -999)
        }
    }
}

