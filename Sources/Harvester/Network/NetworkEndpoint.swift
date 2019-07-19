import Foundation

public enum NetworkEndpoint {
    case fullURL(URL)
    case pathFromBaseURL(String)
}
