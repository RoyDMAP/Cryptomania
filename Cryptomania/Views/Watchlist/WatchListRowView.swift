//
//  WatchListRowView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

// Creates a row that displays one cryptocurrency in your watchlist
struct WatchlistRowView: View {
    let symbol: String // The crypto name like "BTC"
    @EnvironmentObject var cryptoService: CryptoService // Gets current prices
    
    var body: some View {
        // Horizontal layout with left and right sides
        HStack {
            // Left side - crypto name and current price
            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Shows current price if we have the data
                if let crypto = cryptoService.symbols[symbol] {
                    Text("$\(crypto.last)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Pushes content to opposite sides
            Spacer()
            
            // Right side - daily change and high/low prices
            if let crypto = cryptoService.symbols[symbol] {
                VStack(alignment: .trailing, spacing: 2) {
                    // Shows daily change with arrow and percentage
                    HStack(spacing: 4) {
                        Image(systemName: crypto.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        
                        Text("\(crypto.dailyChange >= 0 ? "+" : "")\(String(format: "%.2f", crypto.dailyChange))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(crypto.dailyChange >= 0 ? .green : .red) // Green for up, red for down
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill((crypto.dailyChange >= 0 ? Color.green : Color.red).opacity(0.1))
                    )
                    
                    // Shows today's highest and lowest prices
                    Text("H: $\(crypto.highest) L: $\(crypto.lowest)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                // Shows loading spinner if price data isn't loaded yet
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WatchlistRowView(symbol: "BTC")
        .environmentObject(CryptoService())
}
