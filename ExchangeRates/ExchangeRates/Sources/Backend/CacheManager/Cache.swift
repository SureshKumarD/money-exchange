//
//  Cache.swift
//  Connect
//
//  Created by Suresh on 24/12/20.
//

import Foundation

final public class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    //By default the caching interval set to 30 minutes.
    public init(dateProvider: @escaping () -> Date = Date.init,
                entryLifetime: TimeInterval = 30*60,
                maximumEntryCount: Int = 50) {
        self.dateProvider       = dateProvider
        self.entryLifetime      = entryLifetime
        wrapped.countLimit      = maximumEntryCount
        wrapped.delegate        = keyTracker
    }

    public enum CacheError: Error {
        case replacementError
    }

    // MARK: - Mutators
    public func insert(_ value: Value, forKey key: Key, cache timeInterval: TimeInterval = 0) {
        let date       = dateProvider()
        let expiration = date.addingTimeInterval((timeInterval == 0) ? entryLifetime : timeInterval)
        let entry      = Entry(key: key, value: value, expirationDate: expiration, createdDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    public func removeAll() {
        for key in keyTracker.keys {
            removeValue(forKey: key)
        }
    }

    // MARK: - Accessors
    public func value(forKey key: Key, cache timeInterval: TimeInterval = 0) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        let expirationDate = (timeInterval == 0) ? entry.expirationDate : dateProvider().addingTimeInterval(timeInterval)
        guard dateProvider() < expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    public func values() -> [Value] {
        var values: [Value] = []
        for key in keyTracker.keys {
            if let entry = value(forKey: key) {
                values.append(entry)
            }
        }
        return values
    }

}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience public init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

extension Cache where Key: Codable, Value: Codable {

    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }

}

// MARK: - Private Extensions
private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { return key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        let creationDate: Date

        init(key: Key, value: Value, expirationDate: Date, createdDate: Date) {
            self.key            = key
            self.value          = value
            self.expirationDate = expirationDate
            self.creationDate   = createdDate
        }
    }
}

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }
}

private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}
