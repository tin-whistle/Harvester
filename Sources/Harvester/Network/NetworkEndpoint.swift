import Foundation

enum NetworkEndpoint {
    case fullURL(URL)
    case pathFromBaseURL(String)
}
