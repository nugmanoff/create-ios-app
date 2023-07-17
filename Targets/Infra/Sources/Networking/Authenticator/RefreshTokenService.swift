import Foundation

public typealias Token = String

public protocol RefreshTokenService: AnyObject {
    func refreshToken(_ refreshToken: String, completion: @escaping (Result<Token, Error>) -> Void)
}

extension NetworkClient: RefreshTokenService {
    public func refreshToken(_ refreshToken: String, completion: @escaping (Result<Token, Error>) -> Void) {
        POST(path: "/auth/refresh", params: ["refreshToken": refreshToken], completion: completion)
    }
}
