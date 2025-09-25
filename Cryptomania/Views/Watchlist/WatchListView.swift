//
//  WatchListView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var cryptoService: CryptoService
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var showingAddSymbol = false
    
    var body: some View {
        NavigationView {
            VStack {
                if watchlistManager.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(watchlistManager.watchlist, id: \.self) { symbol in
                            WatchlistRowView(symbol: symbol)
                        }
                        .onDelete(perform: deleteSymbols)
                    }
                    .refreshable {
                        await cryptoService.fetchPrices(for: watchlistManager.watchlist)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingAddSymbol = true
                    }
                    .disabled(!watchlistManager.canAddMore())
                }
            }
            .sheet(isPresented: $showingAddSymbol) {
                AddSymbolView()
            }
            .task {
                if !watchlistManager.isEmpty {
                    await cryptoService.fetchPrices(for: watchlistManager.watchlist)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Start Your Crypto Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Track up to 4 cryptocurrency prices and monitor their performance")
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
    
    private func deleteSymbols(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let symbol = watchlistManager.watchlist[index]
                watchlistManager.removeFromWatchlist(symbol)
            }
        }
    }
}
