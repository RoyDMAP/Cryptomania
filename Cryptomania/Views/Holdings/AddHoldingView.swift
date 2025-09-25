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
    @State private var buyPrice = ""
    @State private var buyDate = Date()
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Holding Details") {
                    TextField("Symbol (e.g., BTC)", text: $symbol)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                    
                    TextField("Buy Price", text: $buyPrice)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Buy Date", selection: $buyDate, in: ...Date(), displayedComponents: .date)
                }
                
                Section("Notes (Optional)") {
                    TextField("Add a note", text: $note, axis: .vertical)
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
        let trimmedPrice = buyPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let symbolValid = !trimmedSymbol.isEmpty
        let priceValid = !trimmedPrice.isEmpty &&
                        Double(trimmedPrice) != nil && (Double(trimmedPrice) ?? 0) > 0
        
        return symbolValid && priceValid
    }
    
    private func saveHolding() {
        guard isFormValid else {
            showError("Please fill in all required fields")
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
            let parsedPrice = Double(buyPrice.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Only set values for attributes that exist
            newHolding.setValue(trimmedSymbol, forKey: "symbol")
            newHolding.setValue(parsedPrice, forKey: "buyPrice")
            newHolding.setValue(buyDate, forKey: "buyAt")
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
