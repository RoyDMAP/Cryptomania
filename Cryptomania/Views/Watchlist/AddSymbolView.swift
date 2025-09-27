//
//  AddSymbolView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

struct AddSymbolView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var newSymbol = ""
    @State private var showingError = false
    
    // Expanded list of popular cryptocurrencies
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
                Section("Enter Symbol") {
                    TextField("Symbol (e.g., BTC)", text: $newSymbol)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                }
                
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
                
                // Optional: Add a section showing current watchlist
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
    
    private var availableSymbols: [String] {
        return popularSymbols.filter { !watchlistManager.isInWatchlist($0) }
    }
    
    private func addSymbol() {
        let success = watchlistManager.addToWatchlist(newSymbol)
        if success {
            dismiss()
        } else {
            showingError = true
        }
    }
}
