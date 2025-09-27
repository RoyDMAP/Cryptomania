//
//  WatchListView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

// Main screen that shows your cryptocurrency watchlist
struct WatchlistView: View {
    @EnvironmentObject var cryptoService: CryptoService // Gets current prices
    @EnvironmentObject var watchlistManager: WatchlistManager // Manages your watchlist
    @State private var showingAddSymbol = false // Controls if add screen is open
    
    var body: some View {
        NavigationView {
            VStack {
                // Show different content based on whether you have items in watchlist
                if watchlistManager.isEmpty {
                    emptyState // Show message when no cryptos in watchlist
                } else {
                    // Show list of all cryptos in your watchlist
                    List {
                        ForEach(watchlistManager.watchlist, id: \.self) { symbol in
                            WatchlistRowView(symbol: symbol)
                        }
                        .onDelete(perform: deleteSymbols) // Swipe to delete
                    }
                    .refreshable {
                        // Pull down to refresh prices
                        await cryptoService.fetchPrices(for: watchlistManager.watchlist)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Circular add button in top right
                    Button(action: {
                        showingAddSymbol = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(watchlistManager.canAddMore() ? Color.blue : Color.gray)
                            )
                    }
                    .disabled(!watchlistManager.canAddMore()) // Disable if watchlist is full
                }
            }
            .sheet(isPresented: $showingAddSymbol) {
                AddSymbolView()
            }
            .task {
                // Get prices when screen first loads
                if !watchlistManager.isEmpty {
                    await cryptoService.fetchPrices(for: watchlistManager.watchlist)
                }
            }
        }
    }
    
    // What to show when your watchlist is empty
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Start Your Crypto Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Track up to 10 cryptocurrency prices and monitor their performance")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Symbol") {
                showingAddSymbol = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // Removes cryptos when user swipes to delete
    private func deleteSymbols(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let symbol = watchlistManager.watchlist[index]
                watchlistManager.removeFromWatchlist(symbol)
            }
        }
    }
}
