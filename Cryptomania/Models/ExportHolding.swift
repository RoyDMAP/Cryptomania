//
//  ExportHolding.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation

struct ExportHolding: Codable {
    let symbol: String
    let amount: Double
    let buyPrice: Double
    let buyAtISO: String
    let currentPrice: Double
    let currentAtISO: String
    let note: String?
    
    var totalValue: Double {
        amount * currentPrice
    }
    
    var totalInvested: Double {
        amount * buyPrice
    }
    
    var profitLoss: Double {
        totalValue - totalInvested
    }
    
    var profitLossPercentage: Double {
        guard totalInvested > 0 else { return 0 }
        return (profitLoss / totalInvested) * 100
    }
}
