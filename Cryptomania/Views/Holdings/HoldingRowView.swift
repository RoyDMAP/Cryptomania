//
//  HoldingRowView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

// Creates a row that displays one cryptocurrency holding
struct HoldingRowView: View {
    let holding: Holding // The crypto purchase data
    @EnvironmentObject var cryptoService: CryptoService // Gets current prices
    
    var body: some View {
        // Horizontal layout with left and right sides
        HStack {
            // Left side - crypto name and purchase info
            VStack(alignment: .leading, spacing: 2) {
                Text(holding.safeSymbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Shows how much you own and what you paid
                Text("\(holding.safeAmount, specifier: "%.4f") @ $\(holding.safeBuyPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Pushes content to opposite sides
            Spacer()
            
            // Right side - current value and profit/loss
            if let currentPrice = cryptoService.getCurrentPrice(for: holding.safeSymbol) {
                VStack(alignment: .trailing, spacing: 2) {
                    // Shows what your crypto is worth now
                    Text("$\(holding.totalCurrentValue(currentPrice: currentPrice), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Calculate profit or loss
                    let pnl = holding.totalProfitLoss(currentPrice: currentPrice)
                    let percentage = holding.profitLossPercentage(currentPrice: currentPrice)
                    
                    // Shows profit/loss in dollars and percentage
                    HStack(spacing: 2) {
                        Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                        Text("(\(pnl >= 0 ? "+" : "")\(percentage, specifier: "%.1f")%)")
                    }
                    .font(.caption)
                    .foregroundColor(pnl >= 0 ? .green : .red) // Green for profit, red for loss
                }
            } else {
                // Shows loading spinner if price isn't available yet
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Text("HoldingRowView Preview")
}
