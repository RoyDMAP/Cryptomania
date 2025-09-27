//
//  HoldingsDocument.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import CoreData

struct HoldingsDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    static var writableContentTypes: [UTType] = [.json]
    
    var holdings: [ExportHolding]
    
    // Creates a new empty document
    init(holdings: [ExportHolding] = []) {
        self.holdings = holdings
    }
    
    // Opens and reads a saved file
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        holdings = try decoder.decode([ExportHolding].self, from: data)
    }
    
    // Saves the document to a file
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(holdings)
        return FileWrapper(regularFileWithContents: data)
    }
    
    // Converts your app data into a file format
    static func from(_ holdings: [Holding], with prices: [String: Double]) -> HoldingsDocument {
        let currentTime = ISO8601DateFormatter().string(from: Date())
        
        let exportData = holdings.compactMap { holding -> ExportHolding? in
            guard let symbolName = holding.symbol,
                  let buyDate = holding.buyAt else {
                return nil
            }
            
            let currentPrice = prices[symbolName] ?? holding.buyPrice
            
            return ExportHolding(
                symbol: symbolName,
                amount: holding.amount,
                buyPrice: holding.buyPrice,
                buyAtISO: ISO8601DateFormatter().string(from: buyDate),
                currentPrice: currentPrice,
                currentAtISO: currentTime,
                note: holding.note
            )
        }
        
        return HoldingsDocument(holdings: exportData)
    }
    
    // Checks if the data is good before saving
    var isValid: Bool {
        return !holdings.isEmpty && holdings.allSatisfy { holding in
            !holding.symbol.isEmpty &&
            holding.amount > 0 &&
            holding.buyPrice > 0 &&
            !holding.buyAtISO.isEmpty
        }
    }
    
    // Creates a text summary of what's in the file
    var summary: String {
        let count = holdings.count
        let symbols = Set(holdings.map { $0.symbol }).sorted().joined(separator: ", ")
        return "\(count) holding\(count == 1 ? "" : "s"): \(symbols)"
    }
}
