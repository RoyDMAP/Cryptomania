//
//  HoldingRowView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

struct HoldingRowView: View {
    let holding: Holding
    @EnvironmentObject var cryptoService: CryptoService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(holding.safeSymbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(holding.safeAmount, specifier: "%.4f") @ $\(holding.safeBuyPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let currentPrice = cryptoService.getCurrentPrice(for: holding.safeSymbol) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(holding.totalCurrentValue(currentPrice: currentPrice), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let pnl = holding.totalProfitLoss(currentPrice: currentPrice)
                    let percentage = holding.profitLossPercentage(currentPrice: currentPrice)
                    
                    HStack(spacing: 2) {
                        Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                        Text("(\(pnl >= 0 ? "+" : "")\(percentage, specifier: "%.1f")%)")
                    }
                    .font(.caption)
                    .foregroundColor(pnl >= 0 ? .green : .red)
                }
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
}
