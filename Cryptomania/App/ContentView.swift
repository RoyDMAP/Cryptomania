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
    @State private var isDarkMode = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "buyAt", ascending: false)]
    ) private var holdings: FetchedResults<NSManagedObject>
    
    init() {
        // Initialize the fetch request
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Holding")
        request.sortDescriptors = [NSSortDescriptor(key: "buyAt", ascending: false)]
        _holdings = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header with title and theme toggle
            VStack(spacing: 12) {
                HStack {
                    Text("Cryptomania")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Spacer()
                    
                    // light to dark toggle
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isDarkMode ? .gray : .orange)
                        
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .scaleEffect(0.8)
                        
                        Image(systemName: "moon.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isDarkMode ? .blue : .gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Portfolio header below the title
                if !holdings.isEmpty {
                    portfolioSummaryCard
                        .padding(.horizontal)
                }
            }
            .background(isDarkMode ? Color.black : Color(UIColor.systemGroupedBackground))
            
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
            .background(isDarkMode ? Color.black : Color.white)
        }
        .background(isDarkMode ? Color.black : Color.white)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            await loadInitialData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            // Refresh on Data change
            Task {
                await loadInitialData()
            }
        }
    }
    
    private var portfolioSummaryCard: some View {
        // calculation: multiply quantity by buy price for total invested
        let totalInvested = holdings.reduce(0.0) { result, holding in
            let quantity = holding.value(forKey: "amount") as? Double ?? 0
            let buyPrice = holding.value(forKey: "buyPrice") as? Double ?? 0
            return result + (quantity * buyPrice)
        }
        
        // calculation: multiply quantity by current price for current value
        let totalCurrent = holdings.reduce(0.0) { result, holding in
            guard let symbol = holding.value(forKey: "symbol") as? String else { return result }
            let quantity = holding.value(forKey: "amount") as? Double ?? 0
            let buyPrice = holding.value(forKey: "buyPrice") as? Double ?? 0
            let currentPrice = cryptoService.getCurrentPrice(for: symbol) ?? buyPrice
            return result + (quantity * currentPrice)
        }
        
        let totalPnL = totalCurrent - totalInvested
        let pnlPercentage = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0
        
        return VStack(spacing: 8) {
            HStack {
                Text("Portfolio Overview")
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Spacer()
                
                Text("\(holdings.count) holding\(holdings.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // creating a horizontal row with left and right spacing
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(totalCurrent, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
                
                Spacer()
                
                // Right side showing profit/loss info
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
            // checks if the user has crypto holdings
            if holdings.count > 0 {
                topHoldingsPreview
            }
        }
        .padding()
        .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    // creates a reusable view component for displaying top holdings
    private var topHoldingsPreview: some View {
        VStack(spacing: 6) {
            Divider()
                .padding(.vertical, 4)
            
            // this is the header row for the section
            HStack {
                Text("Top Holdings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            // creates a row for each holdings
            ForEach(Array(holdings.prefix(3)), id: \.objectID) { holding in
                HStack {
                    let symbol = holding.value(forKey: "symbol") as? String ?? "UNKNOWN"
                    let quantity = holding.value(forKey: "amount") as? Double ?? 0
                    let buyPrice = holding.value(forKey: "buyPrice") as? Double ?? 0
                    let currentPrice = cryptoService.getCurrentPrice(for: symbol) ?? buyPrice
                    let totalValue = quantity * currentPrice
                    let totalInvested = quantity * buyPrice
                    let pnl = totalValue - totalInvested
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(symbol)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(isDarkMode ? .white : .black)
                        
                        Text("\(quantity, specifier: "%.4f") @ $\(buyPrice, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    // current value and profit/loss
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("$\(totalValue, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        // shows profit in green, loss in red
                        Text("\(pnl >= 0 ? "+" : "")$\(pnl, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(pnl >= 0 ? .green : .red)
                    }
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
