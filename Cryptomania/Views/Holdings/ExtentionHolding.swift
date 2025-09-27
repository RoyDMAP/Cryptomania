//
//  ExentionHolding.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation
import CoreData

// Adds helpful functions to the Holding database object
extension Holding {
    // Safe ways to get data that might be missing from the database
    var safeSymbol: String { symbol ?? "UNKNOWN" } // Returns "UNKNOWN" if no symbol saved
    var safeAmount: Double { amount } // How much crypto you own
    var safeBuyPrice: Double { buyPrice } // What you paid per coin
    var safeBuyDate: Date { buyAt ?? Date() } // When you bought it (or today if missing)
    var safeNote: String { note ?? "" } // Your notes (or empty if none)
    
    // Calculates how much your crypto is worth right now
    func totalCurrentValue(currentPrice: Double) -> Double {
        return safeAmount * currentPrice
    }
    
    // Calculates how much money you originally spent
    func totalInvestedValue() -> Double {
        return safeAmount * safeBuyPrice
    }
    
    // Calculates if you made or lost money
    func totalProfitLoss(currentPrice: Double) -> Double {
        return totalCurrentValue(currentPrice: currentPrice) - totalInvestedValue()
    }
    
    // Calculates your profit or loss as a percentage
    func profitLossPercentage(currentPrice: Double) -> Double {
        let invested = totalInvestedValue()
        guard invested > 0 else { return 0 } // Avoid dividing by zero
        return (totalProfitLoss(currentPrice: currentPrice) / invested) * 100
    }
    
    // Creates a nice text summary of this holding's performance
    func displayString(currentPrice: Double) -> String {
        let pnl = totalProfitLoss(currentPrice: currentPrice)
        let percentage = profitLossPercentage(currentPrice: currentPrice)
        let sign = pnl >= 0 ? "+" : "" // Add + for profits, nothing for losses
        return "\(safeSymbol): \(sign)$\(String(format: "%.2f", pnl)) (\(sign)\(String(format: "%.2f", percentage))%)"
    }
}
