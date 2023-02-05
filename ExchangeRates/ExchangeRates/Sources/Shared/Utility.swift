//
//  Utility.swift
//  ExchangeRates
//
//  Created by Suresh on 30/01/23.
//

import Foundation

class Utility {
    
    class func getEncodedData<T: Encodable>(for value: T) -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(value)
            return jsonData

        } catch {
            print("Couldn't encode data")
            return nil
        }
    }
    
    class func getDecodedbject<T: Decodable>(for data: Data, modelType: T.Type) -> Any? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
           print("Couldn't decode data")
            return nil
        }

    }
}
