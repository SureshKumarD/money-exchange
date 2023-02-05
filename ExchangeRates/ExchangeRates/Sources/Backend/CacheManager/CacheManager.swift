//
//  CacheManager.swift
//  ExchangeRates
//
//  Created by Suresh on 25/01/23.
//

import Foundation

final class CacheManager {

    private let cache = Cache<String, Any>()

    class var shared: CacheManager {
        struct SharedInstance {
            static let instance = CacheManager()
        }
        return SharedInstance.instance
    }

    var isCacheEnabled: Bool {
        return true
    }

    func set(key: String, value: Any, lifeTime: TimeInterval = 0) {
        if !isCacheEnabled { return }
        cache.insert(value, forKey: key, cache: lifeTime)
    }

    func get(valueFor key: String) -> Any? {
        if !isCacheEnabled { return nil }
        return cache.value(forKey: key)
    }
}
