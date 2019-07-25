import OAuthSwift
import UIKit
import Harvester

class OAuthSwiftOAuthProvider: OAuthProvider {
    private let oauthSwift: OAuth2Swift
    private let redirectURL: URL
    
    var authorizationParentViewController: UIViewController?

    init(oauthSwift: OAuth2Swift, redirectURL: URL) {
        self.oauthSwift = oauthSwift
        self.redirectURL = redirectURL
        
        if let credential = try? getCredential() as? OAuthSwiftCredential {
            oauthSwift.client.credential.oauthToken = credential.oauthToken
            oauthSwift.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
    }
    
    public var isAuthorized: Bool {
        return !oauthSwift.client.credential.oauthToken.isEmpty
    }

    public func authorize(completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let authorizationParentViewController = authorizationParentViewController else {
            completion(.failure(OAuthError.misconfigured("OAuthSwiftOAuthProvider must have an authorizationParentViewController set before authorization.")))
            return
        }
        
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: authorizationParentViewController, oauthSwift: oauthSwift)
        oauthSwift.authorize(withCallbackURL: redirectURL, scope: "", state: "") { [weak self] result in
            switch result {
            case let .success(token):
                do {
                    try self?.setCredential(token.credential)
                    completion(.success(self?.isAuthorized ?? false))
                } catch OAuthError.security(let errorString) {
                    completion(.failure(OAuthError.security(errorString)))
                } catch {
                    completion(.failure(OAuthError.unknown(error)))
                }
            case let .failure(error):
                completion(.failure(OAuthError.oauth(error)))
            }
        }
    }
    
    public func deauthorize() throws {
        try setCredential(nil)
        oauthSwift.client.credential.oauthToken = ""
        oauthSwift.client.credential.oauthTokenSecret = ""
    }
    
    public func sendAuthorizedRequest(_ url: URL, method: HTTPMethod, headers: [String : String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let oauthSwiftHTTPMethod: OAuthSwiftHTTPRequest.Method
        switch method {
        case .delete:
            oauthSwiftHTTPMethod = .DELETE
        case .get:
            oauthSwiftHTTPMethod = .GET
        case .patch:
            oauthSwiftHTTPMethod = .PATCH
        case .post:
            oauthSwiftHTTPMethod = .POST
        }
        
        oauthSwift.startAuthorizedRequest(url.absoluteString, method: oauthSwiftHTTPMethod, parameters: [:], headers: headers, body: body) { result in
            switch result {
            case let .success(oauthResponse):
                completion(.success(oauthResponse.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Errors

public enum OAuthError: Error {
    case misconfigured(String)
    case unknown(Error)
    case security(String)
    case oauth(Error)
}


// MARK: - Persistence

extension OAuthSwiftOAuthProvider {
    private func getCredential() throws -> NSCoding? {
        var attributes = commonAttributes
        attributes[kSecReturnData] = kCFBooleanTrue
        
        var result: CFTypeRef?
        switch (SecItemCopyMatching(attributes as CFDictionary, &result), result) {
        case (noErr, let data as Data):
            do {
                return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSCoding
            } catch {
                throw OAuthError.security("Failed to read credentials.")
            }
        default:
            return nil
        }
    }
    
    private func setCredential(_ credential: NSCoding?) throws {
        guard let credential = credential else {
            switch SecItemDelete(commonAttributes as CFDictionary) {
            case errSecSuccess:
                return
            default:
                throw OAuthError.security("Failed to delete credentials.")
            }
        }
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: credential, requiringSecureCoding: true) else { return }
        
        let valueAttribute: [CFString: Any] = [
            kSecValueData: data
        ]
        
        let addDictionary = commonAttributes.merging(valueAttribute) { first, _ in
            return first
        }
        
        // Try to add the item.
        switch SecItemAdd(addDictionary as CFDictionary, nil) {
        case errSecDuplicateItem:
            // Update the existing item instead.
            switch SecItemUpdate(commonAttributes as CFDictionary, valueAttribute as CFDictionary) {
            case errSecSuccess:
                return
            default:
                throw OAuthError.security("Failed to update credentials.")
            }
        case errSecSuccess:
            return
        default:
            throw OAuthError.security("Failed to save credentials.")
        }
    }
    
    private var commonAttributes: [CFString: Any] {
        return [kSecAttrAccount: "Credential".data(using: .utf8)!,
                kSecAttrService: "Harvest",
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock]
    }
}
