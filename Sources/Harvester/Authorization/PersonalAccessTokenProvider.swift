import UIKit

public final class PersonalAccessTokenProvider: @unchecked Sendable {

    public var authorizationParentViewController: UIViewController?

    private var localStorage: LocalStorage

    public init(localStorage: LocalStorage = DefaultLocalStorage()) {
        self.localStorage = localStorage
    }
}

extension PersonalAccessTokenProvider: AuthorizationProvider {
    public var accessToken: String? {
        get {
            localStorage.accessToken
        }
        set {
            localStorage.accessToken = newValue
        }
    }

    @MainActor
    public func authorize() async throws -> Bool {
        guard let viewController = authorizationParentViewController else {
            throw AuthorizationProviderError.failed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let alert = UIAlertController(title: "Authorization", message: "Generate a personal access token at https://id.getharvest.com/developers", preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "Personal Access Token"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert, weak self] action in
                self?.accessToken = alert?.textFields?.first?.text
                continuation.resume(returning: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                continuation.resume(throwing: AuthorizationProviderError.canceled)
            })
            alert.addAction(UIAlertAction(title: "Safari", style: .default) { action in
                UIApplication.shared.open(URL(string: "https://id.getharvest.com/developers")!, options: [:], completionHandler: nil)
                continuation.resume(throwing: AuthorizationProviderError.canceled)
            })
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    public func deauthorize() throws {
        accessToken = nil
    }
}
