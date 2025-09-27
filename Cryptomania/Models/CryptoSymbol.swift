//
//  CryptoSymbol.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

// A blueprint for storing cryptocurrency price data
struct CryptoSymbol: Codable, Identifiable {
    let id = UUID() // Unique ID for each crypto
    let symbol: String // The crypto name like "BTC" or "ETH"
    let last: String // Current price as text
    let lastBTC: String // Price compared to Bitcoin
    let lowest: String // Lowest price today
    let highest: String // Highest price today
    let date: String // When this data was updated
    let dailyChangePercentage: String // How much price changed today
    let sourceExchange: String // Which exchange this data came from
    
    // Converts the price text to a number we can use in math
    var lastPrice: Double {
        Double(last) ?? 0.0
    }
    
    // Converts the percentage change text to a number
    var dailyChange: Double {
        Double(dailyChangePercentage) ?? 0.0
    }
    
    // Tells the app how to read JSON data from the internet
    private enum CodingKeys: String, CodingKey {
        case symbol, last, lastBTC, lowest, highest, date, dailyChangePercentage, sourceExchange
    }
    
    // Fake Bitcoin data for testing the app
    static let sampleBTC = CryptoSymbol(
        symbol: "BTC",
        last: "45000.00",
        lastBTC: "1",
        lowest: "44000.00",
        highest: "46000.00",
        date: "2024-01-01 12:00:00",
        dailyChangePercentage: "2.5",
        sourceExchange: "binance"
    )
    
    // Fake Ethereum data for testing the app
    static let sampleETH = CryptoSymbol(
        symbol: "ETH",
        last: "3200.00",
        lastBTC: "0.071",
        lowest: "3100.00",
        highest: "3300.00",
        date: "2024-01-01 12:00:00",
        dailyChangePercentage: "-1.2",
        sourceExchange: "binance"
    )
}
