//
//  File.swift
//  
//
//  Created by Suresh on 13/07/2020.
//

import Foundation
import Combine

extension Exchange {
  
    static public func fetch(baseCurrency: String) -> AnyPublisher<Exchange?, NetworkError> {
        let params: [String: Any] = [
            "base": baseCurrency,
            "app_id" : API.appId,
            "prettyprint" : false,
            "show_alternative" : false]
        return API.shared.request(endpoint: .fetchCurrencies, params: params)
           
    }
    
}
