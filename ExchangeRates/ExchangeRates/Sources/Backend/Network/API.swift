import Foundation
import Combine

public class API {
    static public let shared = API()
    static private let URL_PREFIX = "https://"
    static private let HOST = "openexchangerates.org"
    static private let HOST_AUTH_DOMAIN = "api"
    static let appId = "1bd4903e605940ad96ee458e2dae3f9b"
    
    @Published private var urlSession: URLSession?
    private let decoder: JSONDecoder
    
    private var oauthStateCancellable: AnyCancellable?
        
    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        urlSession = URLSession(configuration: Self.makeSessionConfiguration(token: nil))
        
    }
    
    static private func makeSessionConfiguration(token: String?) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = .shared
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        return configuration
    }
    
    static private func makeURL(endpoint: Endpoint,
                                isJSONAPI: Bool) -> URL {
        var url: URL
        url = URL(string: "\(Self.URL_PREFIX)\(Self.HOST_AUTH_DOMAIN).\(Self.HOST)")!
        url = url.appendingPathComponent(endpoint.path())
        if isJSONAPI {
            url = url.appendingPathExtension("json")
        }
        let component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        return component.url!
    }
    
    static private func makeRequest(url: URL,
                             httpMethod: String = "GET",
                             queryParamsAsBody: Bool,
                             params: [String: Any]? = nil) -> URLRequest {
        var request: URLRequest
        var url = url
        if let params = params {
            request = URLRequest(url: url)
            if httpMethod != "GET" {
                request.httpBody = params.percentEncoded()
            }else {
               
                for (_, value) in params.enumerated() {
                    url = url.appending(value.key, value: value.value as? String)
                }
                request = URLRequest(url: url)
            }
            if queryParamsAsBody {
                request.setValue("application/x-www-form-urlencoded",forHTTPHeaderField: "Content-Type")
            }
        } else {
            request = URLRequest(url: url)
        }
        request.httpMethod = httpMethod
        return request
    }
    
    public func request<T: Decodable>(endpoint: Endpoint,
                                      basicAuthUser: String? = nil,
                                      forceSignedOutURL: Bool = false,
                                      httpMethod: String = "GET",
                                      isJSONEndpoint: Bool = true,
                                      queryParamsAsBody: Bool = false,
                                      params: [String: Any]? = nil) -> AnyPublisher<T ,NetworkError> {
    
      
        return $urlSession
                .compactMap{ $0 }
                .map {
                    $0.dataTaskPublisher(for: Self.makeRequest(url: Self.makeURL(endpoint: endpoint,
                                                                                 isJSONAPI: isJSONEndpoint),
                                                               httpMethod: httpMethod,
                                                               queryParamsAsBody: queryParamsAsBody,
                                                               params: params))
                    }
                
                .flatMap { self.executeRequest(publisher: $0) }
                .eraseToAnyPublisher()
        }
    
    
    public func POST(endpoint: Endpoint,
                     isJSONEndpoint: Bool = true,
                     params: [String: String]? = nil) -> AnyPublisher<NetworkResponse, Never> {
        request(endpoint: endpoint,
                httpMethod: "POST",
                isJSONEndpoint: isJSONEndpoint,
                queryParamsAsBody: true,
                params: params)
            .subscribe(on: DispatchQueue.global())
            .catch { Just(NetworkResponse(error: CustomError.processNetworkError(error: $0))) }
            .eraseToAnyPublisher()
    }
        
    private func executeRequest<T: Decodable>(publisher: URLSession.DataTaskPublisher) -> AnyPublisher<T ,NetworkError> {
        publisher
            .tryMap{ data, response in
                return try NetworkError.processResponse(data: data, response: response)
            }
            .decode(type: T.self, decoder: decoder)
            .mapError{ error in
                if let error = error as? NetworkError {
                    return error
                }else {
                    return NetworkError.parseError(reason: error)
                }
            }
            .eraseToAnyPublisher()
    }
}
