import UIKit
import Harvester
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var harvest: HarvestAPI?
    var oauthProvider: OAuthSwiftOAuthProvider?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let oauth2Swift = OAuth2Swift(consumerKey: "NISV4r5GzW7jPrJYH0eHaCpZ",
                                      consumerSecret: "FGN6RWdK9NEQieuIwm_gawh-uD2_ZdLO0cN0dSLoZIYysTnGXq2qeyjvv4gySY2BAJj_zY0d1bw-BAaMAKO9Wg",
                                      authorizeUrl: "https://id.getharvest.com/oauth2/authorize",
                                      accessTokenUrl: "https://id.getharvest.com/api/v2/oauth2/token",
                                      responseType: "code")
        oauth2Swift.allowMissingStateCheck = true
        oauthProvider = OAuthSwiftOAuthProvider(oauthSwift: oauth2Swift,
                                                redirectURL: URL(string: "https://www.tinwhistlellc.com/harvester-oauth2-callback")!)
        if let oauthProvider = oauthProvider {
            let configuration = HarvestAPIConfiguration(appName: "Harvester Example", contactEmail: "harvester@tinwhistlellc.com", oauthProvider: oauthProvider)
            harvest = HarvestAPI(configuration: configuration)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            print("Received unknown user activity: \(userActivity)")
            return false
        }

        OAuthSwift.handle(url: url)

        return true
    }
}

