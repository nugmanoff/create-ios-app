public protocol NetworkCredentialsProvider {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
}
