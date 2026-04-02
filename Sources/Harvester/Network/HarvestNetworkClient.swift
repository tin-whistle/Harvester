import Foundation

struct HarvestNetworkClient: NetworkClient {
    private let authorizationProvider: AuthorizationProvider
    private let baseURLString = "https://api.harvestapp.com/v2"
    private let userAgent: String

    var accountId: Int?

    init(configuration: HarvestAPIConfiguration) {
        self.authorizationProvider = configuration.authorizationProvider
        userAgent = "\(configuration.appName) (\(configuration.contactEmail))"
    }
}

// MARK: AuthorizedNetworkClient

extension HarvestNetworkClient: AuthorizedNetworkClient {
    var isAuthorized: Bool {
        return authorizationProvider.accessToken != nil
    }

    func authorize() async throws -> Bool {
        do {
            return try await authorizationProvider.authorize()
        } catch let error as AuthorizationProviderError {
            throw HarvestError.authorization(error)
        }
    }

    func deauthorize() throws {
        try authorizationProvider.deauthorize()
    }
}

// MARK: NetworkClient

extension HarvestNetworkClient {

    var baseURL: URL {
        return URL(string: baseURLString)!
    }

    func send<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        guard isAuthorized else {
            throw HarvestError.unauthorized
        }

        var url = urlFrom(request)
        var bodyData: Data? = nil
        var headers = [
            "Harvest-Account-Id": "\(accountId ?? 0)",
            "User-Agent": userAgent,
        ]

        switch request.method {
        case .delete:
            break
        case .get(let queryItems):
            guard queryItems.count > 0 else { break }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        case .patch(let body), .post(let body):
            if let body = body {
                do {
                    bodyData = try JSONEncoder().encode(AnyEncodable(body))
                    headers["Content-Type"] = "application/json"
                } catch {
                    throw HarvestError.encoding(error)
                }
            }
        }

        let id = UUID().uuidString
        print("\(id): Sending \(request.method) \(url)")

        if let accessToken = authorizationProvider.accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = bodyData
        urlRequest.allHTTPHeaderFields = headers

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw HarvestError.unknown(error)
        }

        do {
            print("\(id): Got response: \(String(data: data, encoding: .utf8) ?? "undecodable")")
            let response = try JSONDecoder().decode(T.Response.self, from: data)
            return response
        } catch {
            throw HarvestError.decoding(error)
        }
    }
}
