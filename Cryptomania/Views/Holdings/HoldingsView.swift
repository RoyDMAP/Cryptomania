//
//  HoldingsView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI
import CoreData

// Screen that shows all your cryptocurrency purchases
struct HoldingsView: View {
    @Environment(\.managedObjectContext) private var viewContext // Database connection
    @EnvironmentObject var cryptoService: CryptoService // Gets current prices
    
    // Gets all holdings from database, newest first
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "Holding", in: PersistenceController.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(key: "buyAt", ascending: false)]
    ) private var holdings: FetchedResults<NSManagedObject>
    
    @State private var showingAddHolding = false // Controls if add screen is open
    
    var body: some View {
        NavigationView {
            VStack {
                // Show different content based on whether you have holdings
                if holdings.isEmpty {
                    emptyState // Show message when no holdings
                } else {
                    // Show list of all your holdings
                    List {
                        ForEach(holdings, id: \.objectID) { holding in
                            HoldingRow(holding: holding)
                        }
                        .onDelete(perform: deleteHolding) // Swipe to delete
                    }
                }
            }
            .navigationTitle("Holdings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { showingAddHolding = true }
                }
            }
            .sheet(isPresented: $showingAddHolding) {
                AddHoldingView()
            }
        }
    }
    
    // What to show when you don't have any holdings yet
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No holdings yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your crypto purchases to track profit and loss")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Holding") {
                showingAddHolding = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // Deletes holdings when user swipes to delete
    private func deleteHolding(at offsets: IndexSet) {
        withAnimation {
            let objectsToDelete = offsets.map { holdings[$0] }
            objectsToDelete.forEach(viewContext.delete)
            
            do {
                try viewContext.save() // Save changes to database
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

// Creates one row for each cryptocurrency holding
struct HoldingRow: View {
    let holding: NSManagedObject // The crypto purchase data
    @EnvironmentObject var cryptoService: CryptoService // Gets current prices
    
    var body: some View {
        // Horizontal layout with left and right sides
        HStack {
            // Left side - crypto name and purchase price
            VStack(alignment: .leading, spacing: 2) {
                Text(holdingSymbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("$\(holdingPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Pushes content to opposite sides
            Spacer()
            
            // Right side - current price and profit/loss
            if let currentPrice = cryptoService.getCurrentPrice(for: holdingSymbol) {
                VStack(alignment: .trailing, spacing: 2) {
                    // Current market price
                    Text("$\(currentPrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Calculate and show profit/loss
                    let change = currentPrice - holdingPrice
                    Text("\(change >= 0 ? "+" : "")$\(change, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(change >= 0 ? .green : .red) // Green for profit, red for loss
                }
            } else {
                // Show loading spinner if price isn't loaded yet
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
    
    // Gets the crypto symbol from database (like "BTC")
    private var holdingSymbol: String {
        return holding.value(forKey: "symbol") as? String ?? "UNKNOWN"
    }
    
    // Gets the price you paid from database
    private var holdingPrice: Double {
        return holding.value(forKey: "buyPrice") as? Double ?? 0.0
    }
}

#Preview {
    let context = PersistenceController(inMemory: true).container.viewContext
    
    return HoldingsView()
        .environment(\.managedObjectContext, context)
        .environmentObject(CryptoService())
}
