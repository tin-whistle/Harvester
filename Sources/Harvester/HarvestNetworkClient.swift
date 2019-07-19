import UIKit

public struct HarvestNetworkClient: NetworkClient {
    private let baseURLString = "https://api.harvestapp.com/v2"
    private let userAgent = "Harvester iOS SDK (harvester@tinwhistlellc.com)"
    private var oauthProvider: OAuthProvider
    
    public var accountID: Int?
    
    public init(oauthProvider: OAuthProvider) {
        self.oauthProvider = oauthProvider
    }
}

// MARK: AuthorizedNetworkClient

extension HarvestNetworkClient: AuthorizedNetworkClient {
    public var isAuthorized: Bool {
        return oauthProvider.isAuthorized
    }
    
    public func authorizeWithViewController(_ viewController: UIViewController, completion: @escaping (_ result: Result<Bool, HarvestError>) -> Void) {
        oauthProvider.authorizeWithViewController(viewController, completion: completion)
    }
    
    public func deauthorize() throws {
        try oauthProvider.deauthorize()
    }
    
    public func handleAuthorizationRedirectURL(_ url: URL) {
        oauthProvider.handleAuthorizationRedirectURL(url)
    }
}

// MARK: NetworkClient

extension HarvestNetworkClient {
    
    public var baseURL: URL {
        return URL(string: baseURLString)!
    }
    
    public func send<T: NetworkRequest, U>(_ request: T, completion: @escaping (Result<U, HarvestError>) -> Void) where U == T.Response {
        guard isAuthorized else {
            completion(.failure(HarvestError.unauthorized))
            return
        }
        
        var url = urlFrom(request)
        var bodyData: Data? = nil
        var headers = ["Harvest-Account-Id": "\(accountID ?? 0)", "User-Agent": userAgent]
        
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
