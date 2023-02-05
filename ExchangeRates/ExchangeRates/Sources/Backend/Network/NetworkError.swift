//
//  File.swift
//  
//
//  Created by Suresh on 09/07/2020.
//

import Foundation

public enum NetworkError: Error {
    case unknown(data: Data)
    case message(reason: String, data: Data)
    case parseError(reason: Error)
    case apiError(error: CustomError)
    
    static private let decoder = JSONDecoder()
    
    static func processResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(data: data)
        }
        if (httpResponse.statusCode == 404) {
            throw NetworkError.message(reason: "Resource not found", data: data)
        }
        if 200 ... 299 ~= httpResponse.statusCode {
            return data
        } else {
            do {
                let customError = try decoder.decode(CustomError.self, from: data)
                throw NetworkError.message(reason: "\(String(describing: customError.message ?? "")), \(String(describing: customError.description ?? ""))", data: data)
            }
        }
    }
}
