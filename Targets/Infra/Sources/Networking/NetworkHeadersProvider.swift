import Foundation
import Alamofire

public protocol NetworkHeadersProvider {
    var headers: HTTPHeaders { get }
}
