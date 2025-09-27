//
//  ExportHolding.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

// A template for saving crypto purchases to a file
struct ExportHolding: Codable {
    let symbol: String // The crypto name like "BTC"
    let amount: Double // How much crypto you own
    let buyPrice: Double // What price you paid per coin
    let buyAtISO: String // When you bought it (as text)
    let currentPrice: Double // What the coin is worth now
    let currentAtISO: String // When the current price was updated
    let note: String? // Any notes you wrote about this purchase
    
    // Calculates how much your crypto is worth right now
    var totalValue: Double {
        amount * currentPrice
    }
    
    // Calculates how much money you originally spent
    var totalInvested: Double {
        amount * buyPrice
    }
    
    // Calculates if you made or lost money
    var profitLoss: Double {
        totalValue - totalInvested
    }
    
    // Calculates your profit or loss as a percentage
    var profitLossPercentage: Double {
        guard totalInvested > 0 else { return 0 } // Avoid dividing by zero
        return (profitLoss / totalInvested) * 100
    }
}
