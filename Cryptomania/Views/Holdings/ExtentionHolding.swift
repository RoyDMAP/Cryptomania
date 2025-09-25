//
//  ExentionHolding.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation
import CoreData

extension Holding {
    var safeSymbol: String { symbol ?? "UNKNOWN" }
    var safeAmount: Double { amount }
    var safeBuyPrice: Double { buyPrice }
    var safeBuyDate: Date { buyAt ?? Date() }
    var safeNote: String { note ?? "" }
    
    func totalCurrentValue(currentPrice: Double) -> Double {
        return safeAmount * currentPrice
    }
    
    func totalInvestedValue() -> Double {
        return safeAmount * safeBuyPrice
    }
    
    func totalProfitLoss(currentPrice: Double) -> Double {
        return totalCurrentValue(currentPrice: currentPrice) - totalInvestedValue()
    }
    
    func profitLossPercentage(currentPrice: Double) -> Double {
        let invested = totalInvestedValue()
        guard invested > 0 else { return 0 }
        return (totalProfitLoss(currentPrice: currentPrice) / invested) * 100
    }
    
    func displayString(currentPrice: Double) -> String {
        let pnl = totalProfitLoss(currentPrice: currentPrice)
        let percentage = profitLossPercentage(currentPrice: currentPrice)
        let sign = pnl >= 0 ? "+" : ""
        return "\(safeSymbol): \(sign)$\(String(format: "%.2f", pnl)) (\(sign)\(String(format: "%.2f", percentage))%)"
    }
}
