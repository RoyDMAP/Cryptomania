//
//  ContentView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var cryptoService = CryptoService()
    @StateObject private var watchlistManager = WatchlistManager()
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "buyAt", ascending: false)]
    ) private var holdings: FetchedResults<NSManagedObject>
    
    init() {
        // Initialize the fetch request with the correct entity
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Holding")
        request.sortDescriptors = [NSSortDescriptor(key: "buyAt", ascending: false)]
        _holdings = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header with title
            VStack(spacing: 12) {
                Text("Cryptomania")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Portfolio header below the title
                if !holdings.isEmpty {
                    portfolioSummaryCard
                        .padding(.horizontal)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Tab view below the header
            TabView {
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "list.bullet")
                    }
                    .environmentObject(cryptoService)
                    .environmentObject(watchlistManager)
                
                HoldingsView()
                    .tabItem {
                        Label("Holdings", systemImage: "briefcase")
                    }
                    .environmentObject(cryptoService)
            }
            .accentColor(.blue)
        }
        .task {
            await loadInitialData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            // Refresh data when Core Data saves
            Task {
                await loadInitialData()
            }
        }
    }
    
    private var portfolioSummaryCard: some View {
        let totalInvested = holdings.reduce(0.0) { result, holding in
            let price = holding.value(forKey: "buyPrice") as? Double ?? 0
            return result + price
        }
        
        let totalCurrent = holdings.reduce(0.0) { result, holding in
            guard let symbol = holding.value(forKey: "symbol") as? String else { return result }
            let buyPrice = holding.value(forKey: "buyPrice") as? Double ?? 0
            let currentPrice = cryptoService.getCurrentPrice(for: symbol) ?? buyPrice
            return result + currentPrice
        }
        
        let totalPnL = totalCurrent - totalInvested
        let pnlPercentage = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0
        
        return VStack(spacing: 8) {
            HStack {
                Text("Portfolio Overview")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(holdings.count) holding\(holdings.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(totalCurrent, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("P&L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("\(totalPnL >= 0 ? "+" : "")$\(totalPnL, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("(\(pnlPercentage >= 0 ? "+" : "")\(pnlPercentage, specifier: "%.1f")%)")
                            .font(.caption)
                    }
                    .foregroundColor(totalPnL >= 0 ? .green : .red)
                }
            }
            
            if holdings.count > 0 {
                topHoldingsPreview
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var topHoldingsPreview: some View {
        VStack(spacing: 6) {
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Text("Top Holdings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            ForEach(Array(holdings.prefix(3)), id: \.objectID) { holding in
                HStack {
                    let symbol = holding.value(forKey: "symbol") as? String ?? "UNKNOWN"
                    let buyPrice = holding.value(forKey: "buyPrice") as? Double ?? 0
                    let currentPrice = cryptoService.getCurrentPrice(for: symbol) ?? buyPrice
                    let pnl = currentPrice - buyPrice
                    
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("$\(currentPrice, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                        .font(.caption2)
                        .foregroundColor(pnl >= 0 ? .green : .red)
                }
            }
        }
    }
    
    private func loadInitialData() async {
        // Load prices for both watchlist and holdings
        var symbolsToLoad: Set<String> = Set(watchlistManager.watchlist)
        
        for holding in holdings {
            if let symbol = holding.value(forKey: "symbol") as? String {
                symbolsToLoad.insert(symbol)
            }
        }
        
        if !symbolsToLoad.isEmpty {
            await cryptoService.fetchPrices(for: Array(symbolsToLoad))
        }
    }
}
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
