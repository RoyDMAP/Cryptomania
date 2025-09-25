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
    
    private let popularSymbols = ["BTC", "ETH", "ADA", "SOL", "DOGE", "XRP"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Enter Symbol") {
                    TextField("Symbol (e.g., BTC)", text: $newSymbol)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                }
                
                Section("Popular") {
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
                    Text("Watchlist: \(watchlistManager.watchlist.count)/4")
                        .foregroundColor(.secondary)
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
