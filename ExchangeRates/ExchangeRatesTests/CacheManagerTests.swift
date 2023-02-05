//
//  CacheManagerTests.swift
//  ExchangeRatesTests
//
//  Created by Suresh on 31/01/23.
//

import XCTest
@testable import ExchangeRates


final class CacheManagerTests: XCTestCase {
    
    let testDict = ["sample": "test"]
    let testKey = "sampleTest"
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTimeBasedCache() throws {
        
        if let data = Utility.getEncodedData(for: testDict) {
            //Cache the data for 30 seconds
            CacheManager.shared.set(key: testKey, value: data, lifeTime: 30)
        }
        
        let data = CacheManager.shared.get(valueFor: testKey) as? Data
        let cachedData = Utility.getDecodedbject(for: data ?? Data(), modelType: [String: String].self)
        XCTAssertNotNil(cachedData)
        
      
        let exp = expectation(description: "Fetch Cache after 30 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 5.0)
        if result == XCTWaiter.Result.timedOut {
            let data = CacheManager.shared.get(valueFor: testKey) as? Data
            let cachedData = Utility.getDecodedbject(for: data ?? Data(), modelType: [String: String].self)
            XCTAssertNotNil(cachedData)
            
        } else {
            XCTFail("Delay interrupted")
        }
    }

}
