//
//  CryptoService.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

@MainActor
class CryptoService: ObservableObject {
    @Published var symbols: [String: CryptoSymbol] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    func fetchPrices(for symbolsList: [String]) async {
        guard !symbolsList.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        var newSymbols: [String: CryptoSymbol] = [:]
        let samples = [CryptoSymbol.sampleBTC, CryptoSymbol.sampleETH]
        
        for symbolName in symbolsList {
            if let sample = samples.first(where: { $0.symbol == symbolName }) {
                // Use predefined sample data for known symbols
                newSymbols[symbolName] = sample
            } else {
                // Generate random demo data for unknown symbols
                newSymbols[symbolName] = CryptoSymbol(
                    symbol: symbolName,
                    last: String(format: "%.2f", Double.random(in: 0.1...1000)),
                    lastBTC: "0.001",
                    lowest: "0",
                    highest: "0",
                    date: ISO8601DateFormatter().string(from: Date()),
                    dailyChangePercentage: String(format: "%.2f", Double.random(in: -10...10)),
                    sourceExchange: "demo"
                )
            }
        }
        
        self.symbols = newSymbols
        self.lastUpdated = Date()
        self.isLoading = false
    }
    
    func getCurrentPrice(for symbol: String) -> Double? {
        return symbols[symbol]?.lastPrice
    }
}
