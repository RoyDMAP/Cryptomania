//
//  WatchListRowView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI

struct WatchlistRowView: View {
    let symbol: String
    @EnvironmentObject var cryptoService: CryptoService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let crypto = cryptoService.symbols[symbol] {
                    Text("$\(crypto.last)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let crypto = cryptoService.symbols[symbol] {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: crypto.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        
                        Text("\(crypto.dailyChange >= 0 ? "+" : "")\(String(format: "%.2f", crypto.dailyChange))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(crypto.dailyChange >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill((crypto.dailyChange >= 0 ? Color.green : Color.red).opacity(0.1))
                    )
                    
                    Text("H: $\(crypto.highest) L: $\(crypto.lowest)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
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
