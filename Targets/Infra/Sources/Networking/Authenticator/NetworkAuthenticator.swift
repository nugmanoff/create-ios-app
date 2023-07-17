import Alamofire
import Foundation

public final class NetworkAuthenticator: RequestInterceptor {
    private weak var refreshTokenService: RefreshTokenService?
    private var credentialsProvider: NetworkCredentialsProvider
    private var onTokenRefreshFailed: () -> Void = {}
    
    private var requiresRefresh: Bool {
        accessToken.isEmpty
    }
    
    private var accessToken: String {
        credentialsProvider.accessToken ?? ""
    }
    
    private var refreshToken: String {
        credentialsProvider.refreshToken ?? ""
    }

    public init(
        refreshTokenService: RefreshTokenService,
        credentialsProvider: NetworkCredentialsProvider,
        onTokenRefreshFailed: @escaping () -> Void
    ) {
        self.refreshTokenService = refreshTokenService
        self.credentialsProvider = credentialsProvider
        self.onTokenRefreshFailed = onTokenRefreshFailed
    }
    
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
    
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        defer { lock.unlock() }
        lock.lock()
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing && !requiresRefresh {
                refreshTokens { [weak self] result in
                    guard let self else { return }
                    defer { self.lock.unlock() }
                    lock.lock()
                    requestsToRetry.forEach { completion in
                        completion(.retry)
                    }
                    requestsToRetry.removeAll()
                }
            }
        } else {
            completion(.doNotRetry)
        }
    }
    
    private func refreshTokens(completion: @escaping (RetryResult) -> Void) {
        guard !isRefreshing else { return }

        isRefreshing = true
        
        refreshTokenService?.refreshToken(refreshToken) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(accessToken):
                credentialsProvider.accessToken = accessToken
                completion(.retry)
            case let .failure(error):
                onTokenRefreshFailed()
                completion(.doNotRetryWithError(error))
            }
            isRefreshing = false
        }
    }
}
