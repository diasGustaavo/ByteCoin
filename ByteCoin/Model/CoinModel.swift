import Foundation

struct CoinModel {
    let price: Double
    let fiatName: String
    let cryptoName: String
    
    var priceAsString: String {
        return String(format: "%.2f", price)
    }
}
