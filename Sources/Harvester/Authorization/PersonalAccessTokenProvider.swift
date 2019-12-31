import UIKit

public class PersonalAccessTokenProvider {

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

    public func authorize(completion: @escaping (Result<Bool, AuthorizationProviderError>) -> Void) {
        let alert = UIAlertController(title: "Authorization", message: "Generate a personal access token at https://id.getharvest.com/developers", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Personal Access Token"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert, weak self] action in
            self?.accessToken = alert?.textFields?.first?.text
            completion(.success(true))
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completion(.failure(.canceled))
        })
        alert.addAction(UIAlertAction(title: "Safari", style: .default) { action in
            UIApplication.shared.open(URL(string: "https://id.getharvest.com/developers")!, options: [:], completionHandler: nil)
        })
        authorizationParentViewController?.present(alert, animated: true, completion: nil)
    }

    public func deauthorize() throws {
        accessToken = nil
    }
}
