//
//  AddSymbolView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

// Screen for adding cryptocurrencies to your watchlist
struct AddSymbolView: View {
    @Environment(\.dismiss) var dismiss // Function to close this screen
    @EnvironmentObject var watchlistManager: WatchlistManager // Manages your watchlist
    @State private var newSymbol = "" // What the user types
    @State private var showingError = false // Controls error popup
    
    // List of popular cryptocurrencies to choose from
    private let popularSymbols = [
        // Major cryptocurrencies
        "BTC", "ETH", "BNB", "XRP", "ADA", "SOL", 
        "DOT", "DOGE", "AVAX", "SHIB", "MATIC", "LTC",
        // DeFi & Popular Altcoins  
        "UNI", "LINK", "ATOM", "AAVE", "ALGO", "VET",
        "SAND", "MANA", "CRV", "SUSHI", "COMP", "MKR",
        // Additional popular tokens
        "FIL", "XLM", "BCH", "ETC", "XMR", "THETA"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Section for typing in a crypto symbol
                Section("Enter Symbol") {
                    TextField("Symbol (e.g., BTC)", text: $newSymbol)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                }
                
                // Grid of buttons for popular cryptos
                Section("Popular Cryptocurrencies") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(availableSymbols, id: \.self) { symbol in
                            Button(symbol) {
                                newSymbol = symbol
                                addSymbol()
                            }
                            .buttonStyle(.bordered)
                            .disabled(!watchlistManager.canAddMore())
                        }
                    }
                }
                
                // Shows how many cryptos you can still add
                Section("Status") {
                    HStack {
                        Text("Watchlist: \(watchlistManager.watchlist.count)/10")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if watchlistManager.canAddMore() {
                            Text("\(10 - watchlistManager.watchlist.count) slots remaining")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else {
                            Text("Watchlist full")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Shows your current watchlist with remove buttons
                if !watchlistManager.watchlist.isEmpty {
                    Section("Current Watchlist") {
                        ForEach(watchlistManager.watchlist, id: \.self) { symbol in
                            HStack {
                                Text(symbol)
                                    .font(.headline)
                                Spacer()
                                Button("Remove") {
                                    watchlistManager.removeFromWatchlist(symbol)
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addSymbol() }
                        .disabled(newSymbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !watchlistManager.canAddMore())
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(watchlistManager.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // Only shows cryptos that aren't already in your watchlist
    private var availableSymbols: [String] {
        return popularSymbols.filter { !watchlistManager.isInWatchlist($0) }
    }
    
    // Tries to add the crypto to your watchlist
    private func addSymbol() {
        let success = watchlistManager.addToWatchlist(newSymbol)
        if success {
            dismiss() // Close screen if successful
        } else {
            showingError = true // Show error if it failed
        }
    }
}
