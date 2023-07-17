import Foundation
import Alamofire
import Pulse

public final class NetworkClient {
    var session: Session
    
    private let baseURL: String
    private let headersProvider: NetworkHeadersProvider
    private let credentialsProvider: NetworkCredentialsProvider
    private let onTokenRefreshFailed: () -> Void = {}
    private lazy var authenticator = NetworkAuthenticator(
        refreshTokenService: self,
        credentialsProvider: credentialsProvider,
        onTokenRefreshFailed: onTokenRefreshFailed
    )
 
    public init(
        baseURL: String,
        headersProvider: NetworkHeadersProvider,
        credentialsProvider: NetworkCredentialsProvider,
        onTokenRefreshFailed: () -> Void = {}
    ) {
        self.baseURL = baseURL
        self.headersProvider = headersProvider
        self.credentialsProvider = credentialsProvider
        #if DEBUG
        URLSessionProxyDelegate.enableAutomaticRegistration()
        #endif
        session = Session.default
        session.sessionConfiguration.timeoutIntervalForRequest = 30
        session.sessionConfiguration.waitsForConnectivity = true
    }
    
    public func GET<T: Decodable>(
        path: String,
        params: [String: Any] = [:],
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequest(
            path: path,
            method: .get,
            encoding: URLEncoding.default,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
    
    public func POST<T: Decodable, Q: Encodable>(
        path: String,
        params: Q,
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequestWithBody(
            path: path,
            method: .post,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
    
    public func PATCH<T: Decodable, Q: Encodable>(
        path: String,
        params: Q,
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequestWithBody(
            path: path,
            method: .patch,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
    
    public func PUT<T: Decodable, Q: Encodable>(
        path: String,
        params: Q,
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequestWithBody(
            path: path,
            method: .put,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
    
    private func makeRequest<T: Decodable>(
        path: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        params: [String: Any],
        interceptor: RequestInterceptor?
    ) async throws -> T {
        let task = session.request(
            URL(string: baseURL + path)!,
            method: method,
            parameters: params,
            encoding: encoding,
            headers: headersProvider.headers,
            interceptor: interceptor
        )
        .validate()
        .serializingDecodable(T.self)
        
        let result = await task.response.result
        switch result {
        case let .success(value):
            return value
        case let .failure(error):
            throw mapError(error)
        }
    }
        
    private func makeRequestWithBody<T: Decodable, Q: Encodable>(
        path: String,
        method: HTTPMethod,
        params: Q,
        interceptor: RequestInterceptor?
    ) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 10
        request.httpBody = try! JSONEncoder().encode(params)
        request.headers = headersProvider.headers

        let task = session.request(
            request,
            interceptor: interceptor
        )
        .validate()
        .serializingDecodable(T.self)
        
        let result = await task.response.result
        switch result {
        case let .success(value):
            return value
        case let .failure(error):
            throw mapError(error)
        }
    }
}

extension NetworkClient {
    func POST<T: Decodable>(path: String, params: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        session.request(
            URL(string: baseURL + path)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headersProvider.headers
        )
        .validate()
        .responseDecodable(of: T.self) { response in
            if let value = response.value {
                completion(.success(value))
            }
            if let error = response.error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError()))
            }
        }
    }
    
    func POST<T: Decodable>(
        path: String,
        params: [String: Any] = [:],
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequest(
            path: path,
            method: .post,
            encoding: JSONEncoding.default,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
    
    func DELETE<T: Decodable>(
        path: String,
        params: [String: Any] = [:],
        shouldAuthenticate: Bool = true
    ) async throws -> T {
        try await makeRequest(
            path: path,
            method: .delete,
            encoding: JSONEncoding.default,
            params: params,
            interceptor: shouldAuthenticate ? authenticator : nil
        )
    }
}

