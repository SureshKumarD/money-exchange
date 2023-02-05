import Foundation

public enum Endpoint {
    case fetchCurrencies
    
    func path() -> String {
        switch self {
        case .fetchCurrencies:
            return "latest"
        }
    }
}
