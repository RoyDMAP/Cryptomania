//
//  HoldingsView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI
import CoreData

struct HoldingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cryptoService: CryptoService
    
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "Holding", in: PersistenceController.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(key: "buyAt", ascending: false)]
    ) private var holdings: FetchedResults<NSManagedObject>
    
    @State private var showingAddHolding = false
    
    var body: some View {
        NavigationView {
            VStack {
                if holdings.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(holdings, id: \.objectID) { holding in
                            HoldingRow(holding: holding)
                        }
                        .onDelete(perform: deleteHolding)
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
    
    private func deleteHolding(at offsets: IndexSet) {
        withAnimation {
            let objectsToDelete = offsets.map { holdings[$0] }
            objectsToDelete.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

struct HoldingRow: View {
    let holding: NSManagedObject
    @EnvironmentObject var cryptoService: CryptoService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(holdingSymbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("$\(holdingPrice, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let currentPrice = cryptoService.getCurrentPrice(for: holdingSymbol) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(currentPrice, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    let change = currentPrice - holdingPrice
                    Text("\(change >= 0 ? "+" : "")$\(change, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var holdingSymbol: String {
        return holding.value(forKey: "symbol") as? String ?? "UNKNOWN"
    }
    
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
