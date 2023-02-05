//
//  Exchange.swift
//  ExchangeRates
//
//  Created by Suresh on 25/01/23.
//

import Foundation

struct Exchange: Codable {
    var disclaimer, license, base : String?
    var timestamp: TimeInterval?
    var rates: [String: Double]?
    init() {
        
    }
    
    enum CodingKeys: CodingKey {
        case disclaimer
        case license
        case base
        case timestamp
        case rates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        self.license = try container.decodeIfPresent(String.self, forKey: .license)
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        self.rates = try container.decodeIfPresent([String : Double].self, forKey: .rates)
    }

}

