import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, coinPrice: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    let tempFullURL = "https://rest.coinapi.io/v1/exchangerate/BTC/BRL?apikey=32D24346-D231-4CC5-93A0-7110C238A91D"
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "32D24346-D231-4CC5-93A0-7110C238A91D"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let fullURL = "https://rest.coinapi.io/v1/exchangerate/BTC/\(currency)?apikey=\(apiKey)"
        fetchPrice(with: fullURL)
    }
    
    func fetchPrice(with urlString: String) {
        // 1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let prices = parseJSON(safeData) {
                        delegate?.didUpdatePrice(self, coinPrice: prices)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CoinData.self, from: coinData)
            return CoinModel(price: decodeData.rate, fiatName: decodeData.asset_id_quote, cryptoName: decodeData.asset_id_base)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
