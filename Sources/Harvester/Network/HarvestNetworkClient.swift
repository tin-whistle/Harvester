import UIKit

struct HarvestNetworkClient: NetworkClient {
    private let baseURLString = "https://api.harvestapp.com/v2"
    private let userAgent: String
    private var oauthProvider: OAuthProvider
    
    var accountId: Int?
    
    init(configuration: HarvestAPIConfiguration) {
        self.oauthProvider = configuration.oauthProvider
        userAgent = "\(configuration.appName) (\(configuration.contactEmail))"
    }
}

// MARK: AuthorizedNetworkClient

extension HarvestNetworkClient: AuthorizedNetworkClient {
    var isAuthorized: Bool {
        return oauthProvider.isAuthorized
    }
    
    func authorize(completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void) {
        oauthProvider.authorize { result in
            switch result {
            case .failure(let error):
                completion(.failure(.oauth(error)))
            case .success(let authorized):
                completion(.success(authorized))
            }
        }
    }
    
    func deauthorize() throws {
        try oauthProvider.deauthorize()
    }
}

// MARK: NetworkClient

extension HarvestNetworkClient {
    
    var baseURL: URL {
        return URL(string: baseURLString)!
    }
    
    func send<T: NetworkRequest, U>(_ request: T, completion: @escaping (Result<U, HarvestError>) -> Void) where U == T.Response {
        guard isAuthorized else {
            completion(.failure(HarvestError.unauthorized))
            return
        }
        
        var url = urlFrom(request)
        var bodyData: Data? = nil
        var headers = ["Harvest-Account-Id": "\(accountId ?? 0)", "User-Agent": userAgent]
        
        switch request.method {
        case .delete:
            break
        case let .get(queryItems):
            guard queryItems.count > 0 else { break }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        case let .patch(body), let .post(body):
            if let body = body {
                do {
                    bodyData = try JSONEncoder().encode(AnyEncodable(body))
                    headers["Content-Type"] = "application/json"
                } catch {
                    completion(.failure(HarvestError.encoding(error)))
                    return
                }
            }
        }
        
        oauthProvider.sendAuthorizedRequest(url, method: request.method, headers: headers, body: bodyData) { result in
            switch result {
            case let .success(data):
                do {
                    print("Got response to \(url): \(String(data: data, encoding: .utf8) ?? "undecodable")")
                    let response = try JSONDecoder().decode(T.Response.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(HarvestError.decoding(error)))
                }
            case let .failure(error):
                completion(.failure(HarvestError.oauth(error)))
            }
        }
    }
}
