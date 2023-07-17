import Alamofire
import Foundation

extension NetworkClient {
    func mapError(_ error: AFError) -> AFError {
        return error
    }
    func mapError(_ error: AFError) -> NetworkError {
        if let err = error.underlyingError as? URLError, err.code == .notConnectedToInternet || err.code == .dataNotAllowed {
            return NoInternetError(statusCode: URLError.Code.notConnectedToInternet.rawValue)
        } else if error.isParameterEncodingError || error.isParameterEncoderError || error.isResponseSerializationError {
            return DecodingError(statusCode: error.responseCode)
        } else {
            return ServerError(statusCode: error.responseCode)
        }
    }
}

public typealias StatusCode = Int

public class NetworkError {
    public var statusCode: StatusCode?
    
    public var isRetryable: Bool {
        false
    }
    
    public var message: String {
        ""
    }
    
    public init(statusCode: StatusCode? = nil) {
        self.statusCode = statusCode
    }
}

public class NoInternetError: NetworkError {
    public override var message: String {
        "No Internet Error"
    }
    
    public override var isRetryable: Bool {
        true
    }
}

public class DecodingError: NetworkError {
    public override var message: String {
        "Decoding Error"
    }
    
    public override var isRetryable: Bool {
        false
    }
}

public class ServerError: NetworkError {
    public override var message: String {
        "Server Error"
    }
    
    public override var isRetryable: Bool {
        false
    }
    
}

public class RetryableServerError: NetworkError {
    public override var message: String {
        "Retryable Server Error"
    }
    
    public override var isRetryable: Bool {
        true
    }
}
