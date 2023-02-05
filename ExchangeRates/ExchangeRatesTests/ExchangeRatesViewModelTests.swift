//
//  ExchangeRatesViewModelTests.swift
//  ExchangeRatesTests
//
//  Created by Suresh on 31/01/23.
//

import XCTest
@testable import ExchangeRates


final class ExchangeRatesViewModelTests: XCTestCase {
    
    private let developerAppId = "1bd4903e605940ad96ee458e2dae3f9b"
    private var viewModel =  ExchangeRatesViewModel()
    override func setUpWithError() throws {
//        viewModel = ExchangeRatesViewModel()
    }

    override func tearDownWithError() throws {
        //Nothing to reset.
    }

    
    func testInitialValues() throws {
        XCTAssertEqual(viewModel.baseCurrency, "USD")
        XCTAssertEqual(viewModel.enteredAmount, 0)
        XCTAssertEqual(viewModel.cacheEnabled, true)
        XCTAssertEqual(viewModel.cacheLifeTime, 30 * 60)
    }
    
    func testFetchExchangeRatesError() {
        viewModel.fetchExchangeRates(enteredAmount: 1.0, baseCurrency: "JPY")
        
        let exp = expectation(description: "Fetch Exchange Rates Error - tested")
        let result = XCTWaiter.wait(for: [exp], timeout: 30)
        if result == XCTWaiter.Result.timedOut, developerAppId == API.appId {
            XCTAssertNotNil(self.viewModel.error)
            XCTAssertNil(self.viewModel.exchange)
        }
    }
    
    func testFetchExchangeRatesResponse() {
        viewModel.fetchExchangeRates(enteredAmount: 1.0, baseCurrency: "USD")
        
        let exp = expectation(description: "Fetch Exchange Rates Response - tested")
        let result = XCTWaiter.wait(for: [exp], timeout: 30)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertNil(self.viewModel.error)
            XCTAssertNotNil(self.viewModel.exchange)
            XCTAssertNotNil(self.viewModel.exchange?.rates)
        }
    }
    
}

