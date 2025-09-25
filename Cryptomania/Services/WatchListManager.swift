//
//  WatchListManager.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

class WatchlistManager: ObservableObject {
    @Published var watchlist: [String] = []
    @Published var errorMessage: String?
    
    private let maxWatchlistSize = 4
    private let userDefaultsKey = "crypto_watchlist"
    
    init() {
        loadWatchlist()
    }
    
    func addToWatchlist(_ symbol: String) -> Bool {
        let cleanSymbol = symbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        errorMessage = nil
        
        guard !cleanSymbol.isEmpty else {
            errorMessage = "Symbol cannot be empty"
            return false
        }
        
        guard !watchlist.contains(cleanSymbol) else {
            errorMessage = "\(cleanSymbol) is already in your watchlist"
            return false
        }
        
        guard watchlist.count < maxWatchlistSize else {
            errorMessage = "Watchlist is full (maximum \(maxWatchlistSize) symbols)"
            return false
        }
        
        watchlist.append(cleanSymbol)
        saveWatchlist()
        return true
    }
    
    func removeFromWatchlist(_ symbol: String) {
        let uppercaseSymbol = symbol.uppercased()
        watchlist.removeAll { $0 == uppercaseSymbol }
        saveWatchlist()
        errorMessage = nil
    }
    
    func canAddMore() -> Bool {
        return watchlist.count < maxWatchlistSize
    }
    
    func isInWatchlist(_ symbol: String) -> Bool {
        return watchlist.contains(symbol.uppercased())
    }
    
    func availableSlots() -> Int {
        return maxWatchlistSize - watchlist.count
    }
    
    var isEmpty: Bool {
        return watchlist.isEmpty
    }
    
    var isFull: Bool {
        return watchlist.count >= maxWatchlistSize
    }
    
    private func saveWatchlist() {
        UserDefaults.standard.set(watchlist, forKey: userDefaultsKey)
    }
    
    private func loadWatchlist() {
        watchlist = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        
        // Ensure we don't exceed max size in case of corrupted data
        if watchlist.count > maxWatchlistSize {
            watchlist = Array(watchlist.prefix(maxWatchlistSize))
            saveWatchlist()
        }
    }
}
