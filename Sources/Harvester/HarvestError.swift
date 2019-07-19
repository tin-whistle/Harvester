public enum HarvestError: Error {
    case decoding(Error)
    case encoding(Error)
    case oauth(Error)
    case security(String)
    case unauthorized
    case unknown(Error)
}
