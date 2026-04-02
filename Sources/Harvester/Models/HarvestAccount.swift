import Foundation

public struct HarvestAccount: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let product: HarvestProduct
    
    public init(id: Int, name: String, product: HarvestProduct) {
        self.id = id
        self.name = name
        self.product = product
    }
    
    public enum HarvestProduct: String, Codable, Sendable {
        case harvest = "harvest"
        case forecast = "forecast"
    }
}
