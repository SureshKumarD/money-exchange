//
//  ExchangeRatesViewModel.swift
//  ExchangeRates
//
//  Created by Suresh on 26/01/23.
//

import Foundation
import Combine

final class ExchangeRatesViewModel: ObservableObject {
    @Published var exchange: Exchange? {
        didSet {
            if let currencies = exchange?.rates?.keys.map({ $0 }).sorted() as? [String] {
                self.currencies = currencies
            }
        }
    }
    @Published var enteredAmount: Double = 0
    @Published var currencies: [String] = []
    @Published var baseCurrency = "" {
        didSet {
            if !baseCurrency.isEmpty  {
                self.fetchExchangeRates(enteredAmount: self.enteredAmount, baseCurrency: self.baseCurrency)
            }
           
        }
    }
    @Published var isLoading = false
    var error: CustomError?
    let cacheEnabled: Bool
    private var cancellableStore: [AnyCancellable] = []

    init(cacheEnabled: Bool = true) {
        self.baseCurrency = "USD"
        self.enteredAmount = 0
        self.currencies = ["USD"]
        self.cacheEnabled = cacheEnabled
      
        $enteredAmount
                    //debounce/throttle for 0.8 second
                    .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
                    .removeDuplicates()
                    .map({ (value) -> Double? in
                        if value == 0 {
                            self.exchange = nil
                            return nil
                        }
                        return value
                    })
                    .compactMap{ $0 }
                    .sink { (_) in
                    } receiveValue: { [self] (searchText) in
                        if exchange != nil || baseCurrency.isEmpty {
                            isLoading = false
                        } else {
                            isLoading = true
                            fetchExchangeRates(enteredAmount: Double(searchText), baseCurrency: baseCurrency)
                        }
                    }.store(in: &cancellableStore)
        
        $baseCurrency
            .sink { value in
                if self.baseCurrency == value {
                    self.isLoading = false
                    self.exchange = nil
                } else {
                    self.isLoading = true
                    self.fetchExchangeRates(enteredAmount: Double(self.enteredAmount), baseCurrency: value)
                }

            }.store(in: &cancellableStore)
    }
    
    func fetchExchangeRates(enteredAmount: Double, baseCurrency: String) {
        exchange = nil
        
        //Before hitting the actual server, check if the data is available in cache.
        if let exchange = isCacheDataAvailable(for: baseCurrency) {
            self.exchange = exchange
            self.isLoading = false
            self.error = nil
            return
        }
        
        let cancellable = Exchange.fetch(baseCurrency: baseCurrency)
            .receive(on: DispatchQueue.main)
            .map{ $0 }
            .sink { completion in
                self.exchange = nil
                switch completion {
                case .failure(let error):
                    switch error {
                    case .apiError(let apiError):
                        self.error = apiError
                    case .parseError(let parseError):
                        self.error = CustomError(message: parseError.localizedDescription, status: 422)
                    case .message(let reason, _):
                        self.error = CustomError(message: reason, status: nil)
                    default:
                        self.error = CustomError(message: "Unknown Error", status: nil)
                    }
                    print("Error recieved \(self.error?.message ?? "")")
                    self.isLoading = false
                case .finished:
                    return
                }
                
            } receiveValue:{ [weak self] exchange in
                    self?.exchange = exchange
                    self?.isLoading = false
                
                //Save the response to cache.
                if let data = Utility.getEncodedData(for: exchange),
                    let cacheLifeTime = self?.cacheLifeTime, cacheLifeTime > 0 {
                    CacheManager.shared.set(key: baseCurrency, value: data, lifeTime: cacheLifeTime)
                }
                self?.error = nil
            }
            
        cancellableStore.append(cancellable)
    }
}

extension ExchangeRatesViewModel {
    var cacheLifeTime: TimeInterval {
        //Cache life time is set to 30 minutes.
        return cacheEnabled ? 30 * 60 : 0
    }
    
   
}


extension ExchangeRatesViewModel {
    
    func isCacheDataAvailable(for baseCurrency: String) -> Exchange? {
        if let data = CacheManager.shared.get(valueFor: baseCurrency)as? Data,
           let exchange = Utility.getDecodedbject(for: data, modelType: Exchange.self) as? Exchange {
            print("Loaded from Cache, -------------------------\n\(String(data: data, encoding: .utf8)!)\n-------------------------")
            return exchange
        }
        return nil
    }
    
    
 
}

