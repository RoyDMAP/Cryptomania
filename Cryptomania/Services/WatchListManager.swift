//
//  WatchListManager.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

// Manages your list of cryptocurrencies you want to track
class WatchlistManager: ObservableObject {
    @Published var watchlist: [String] = [] // List of crypto symbols you're watching
    @Published var errorMessage: String? // Stores error messages to show users
    
    private let maxWatchlistSize = 10 // Maximum 10 cryptos allowed
    private let userDefaultsKey = "crypto_watchlist" // Key for saving data
    
    // Runs when the app starts - loads your saved watchlist
    init() {
        loadWatchlist()
    }
    
    // Adds a new cryptocurrency to your watchlist
    func addToWatchlist(_ symbol: String) -> Bool {
        let cleanSymbol = symbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        errorMessage = nil // Clear any old errors
        
        // Check if symbol is empty
        guard !cleanSymbol.isEmpty else {
            errorMessage = "Symbol cannot be empty"
            return false
        }
        
        // Check if already in watchlist
        guard !watchlist.contains(cleanSymbol) else {
            errorMessage = "\(cleanSymbol) is already in your watchlist"
            return false
        }
        
        // Check if watchlist is full
        guard watchlist.count < maxWatchlistSize else {
            errorMessage = "Watchlist is full (maximum \(maxWatchlistSize) symbols)"
            return false
        }
        
        watchlist.append(cleanSymbol) // Add to list
        saveWatchlist() // Save to phone storage
        return true
    }
    
    // Removes a cryptocurrency from your watchlist
    func removeFromWatchlist(_ symbol: String) {
        let uppercaseSymbol = symbol.uppercased()
        watchlist.removeAll { $0 == uppercaseSymbol }
        saveWatchlist() // Save changes to phone storage
        errorMessage = nil
    }
    
    // Checks if you can add more cryptos
    func canAddMore() -> Bool {
        return watchlist.count < maxWatchlistSize
    }
    
    // Checks if a crypto is already in your watchlist
    func isInWatchlist(_ symbol: String) -> Bool {
        return watchlist.contains(symbol.uppercased())
    }
    
    // Tells you how many more cryptos you can add
    func availableSlots() -> Int {
        return maxWatchlistSize - watchlist.count
    }
    
    // Checks if your watchlist is empty
    var isEmpty: Bool {
        return watchlist.isEmpty
    }
    
    // Checks if your watchlist is full
    var isFull: Bool {
        return watchlist.count >= maxWatchlistSize
    }
    
    // Saves your watchlist to your phone's storage
    private func saveWatchlist() {
        UserDefaults.standard.set(watchlist, forKey: userDefaultsKey)
    }
    
    // Loads your saved watchlist when the app starts
    private func loadWatchlist() {
        watchlist = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        
        // Fix corrupted data by limiting to max size
        if watchlist.count > maxWatchlistSize {
            watchlist = Array(watchlist.prefix(maxWatchlistSize))
            saveWatchlist()
        }
    }
}
