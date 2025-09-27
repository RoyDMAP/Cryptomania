//
//  CryptoService.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

@MainActor
// Manages getting cryptocurrency prices from the internet
class CryptoService: ObservableObject {
    @Published var symbols: [String: CryptoSymbol] = [:] // Stores all the crypto data
    @Published var isLoading = false // Shows if we're currently getting new prices
    @Published var errorMessage: String? // Stores any error messages
    @Published var lastUpdated: Date? // When we last got new prices
    
    // Gets current prices for a list of cryptocurrencies
    func fetchPrices(for symbolsList: [String]) async {
        guard !symbolsList.isEmpty else { return } // Don't do anything if list is empty
        
        isLoading = true // Show that we're loading
        errorMessage = nil // Clear any old error messages
        
        // Wait 1 second to simulate internet delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        var newSymbols: [String: CryptoSymbol] = [:] // Temporary storage for new data
        let samples = [CryptoSymbol.sampleBTC, CryptoSymbol.sampleETH] // Fake data to use
        
        // Go through each crypto symbol we need prices for
        for symbolName in symbolsList {
            if let sample = samples.first(where: { $0.symbol == symbolName }) {
                // Use fake data for BTC and ETH
                newSymbols[symbolName] = sample
            } else {
                // Create random fake data for other cryptocurrencies
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
        
        self.symbols = newSymbols // Save all the new price data
        self.lastUpdated = Date() // Record when we updated
        self.isLoading = false // Stop showing loading indicator
    }
    
    // Gets the current price for one specific cryptocurrency
    func getCurrentPrice(for symbol: String) -> Double? {
        return symbols[symbol]?.lastPrice
    }
}
