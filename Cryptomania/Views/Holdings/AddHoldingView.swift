//
//  AddHoldingView.swift
//  Cryptomania
//
//  Created by Roy Dimapilis on 9/24/25.
//

import SwiftUI
import CoreData

struct AddHoldingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var symbol = ""
    @State private var quantity = ""
    @State private var buyPrice = ""
    @State private var buyDate = Date()
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Popular symbols for quick selection
    private let popularSymbols = ["BTC", "ETH", "ADA", "SOL", "DOGE", "XRP", "BNB", "MATIC"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cryptocurrency") {
                    TextField("Symbol (e.g., BTC)", text: $symbol)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                    
                    // Quick symbol selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(popularSymbols, id: \.self) { popularSymbol in
                                Button(popularSymbol) {
                                    symbol = popularSymbol
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                Section("Purchase Details") {
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.decimalPad)
                    
                    TextField("Price per unit", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Purchase Date", selection: $buyDate, in: ...Date(), displayedComponents: .date)
                }
                
                // Show calculated total investment
                if let quantityValue = Double(quantity.trimmingCharacters(in: .whitespacesAndNewlines)),
                   let priceValue = Double(buyPrice.trimmingCharacters(in: .whitespacesAndNewlines)),
                   quantityValue > 0 && priceValue > 0 {
                    Section("Investment Summary") {
                        HStack {
                            Text("Total Investment")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(quantityValue * priceValue, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Quantity")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(quantityValue, specifier: "%.6f") \(symbol.uppercased())")
                        }
                        
                        HStack {
                            Text("Price per unit")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(priceValue, specifier: "%.2f")")
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add a note about this purchase", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveHolding() }
                        .disabled(!isFormValid)
                        .fontWeight(.semibold)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        let trimmedSymbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQuantity = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = buyPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let symbolValid = !trimmedSymbol.isEmpty
        let quantityValid = !trimmedQuantity.isEmpty &&
                           Double(trimmedQuantity) != nil && (Double(trimmedQuantity) ?? 0) > 0
        let priceValid = !trimmedPrice.isEmpty &&
                        Double(trimmedPrice) != nil && (Double(trimmedPrice) ?? 0) > 0
        
        return symbolValid && quantityValid && priceValid
    }
    
    private func saveHolding() {
        guard isFormValid else {
            showError("Please fill in all required fields with valid values")
            return
        }
        
        do {
            let entity = NSEntityDescription.entity(forEntityName: "Holding", in: viewContext)
            guard let entity = entity else {
                showError("Could not find Holding entity")
                return
            }
            
            let newHolding = NSManagedObject(entity: entity, insertInto: viewContext)
            
            let trimmedSymbol = symbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let parsedQuantity = Double(quantity.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            let parsedPrice = Double(buyPrice.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Set all required values
            newHolding.setValue(trimmedSymbol, forKey: "symbol")
            newHolding.setValue(parsedQuantity, forKey: "amount") // Using "amount" to match your Core Data model
            newHolding.setValue(parsedPrice, forKey: "buyPrice")
            newHolding.setValue(buyDate, forKey: "buyAt")
            
            // Optional note
            if !trimmedNote.isEmpty {
                newHolding.setValue(trimmedNote, forKey: "note")
            }
            
            try viewContext.save()
            dismiss()
        } catch {
            showError("Failed to save holding: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
#Preview {
    AddHoldingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
