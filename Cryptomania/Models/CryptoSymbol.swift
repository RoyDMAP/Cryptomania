//
//  CryptoSymbol.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

struct CryptoSymbol: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let last: String
    let lastBTC: String
    let lowest: String
    let highest: String
    let date: String
    let dailyChangePercentage: String
    let sourceExchange: String
    
    var lastPrice: Double {
        Double(last) ?? 0.0
    }
    
    var dailyChange: Double {
        Double(dailyChangePercentage) ?? 0.0
    }
    
    private enum CodingKeys: String, CodingKey {
        case symbol, last, lastBTC, lowest, highest, date, dailyChangePercentage, sourceExchange
    }
    
    // Sample data for testing and demo
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
