public enum HarvestError: Error {
    case authorization(Error)
    case decoding(Error)
    case encoding(Error)
    case responseDataMissing
    case security(String)
    case unauthorized
    case unknown(Error)
}
