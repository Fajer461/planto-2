//
//  remiderview model.swift
//  planto 2
//
//  Created by Fajer saleh on 04/05/1447 AH.
//
import Foundation
import SwiftUI
internal import Combine

// MARK: - Plant Reminder View Model
class PlantReminderViewModel: ObservableObject {
    @Published var plantReminders: [PlantReminder] = []
    
    var checkedCount: Int {
        plantReminders.filter { $0.isChecked }.count
    }
    
    var progressPercentage: Double {
        guard !plantReminders.isEmpty else { return 0 }
        return Double(checkedCount) / Double(plantReminders.count)
    }
    
    var hasPlants: Bool {
        !plantReminders.isEmpty
    }
    
    func addPlant(_ plant: PlantReminder) {
        plantReminders.append(plant)
        savePlants()
    }
    
    // MARK: - Update Plant
    
    func updatePlant(_ plant: PlantReminder) {
        if let index = plantReminders.firstIndex(where: { $0.id == plant.id }) {
            plantReminders[index] = plant
            savePlants()
        }
    }
    
    func deletePlant(_ plant: PlantReminder) {
        plantReminders.removeAll { $0.id == plant.id }
        savePlants()
    }
    
    func toggleCheck(for plant: PlantReminder) {
        if let index = plantReminders.firstIndex(where: { $0.id == plant.id }) {
            plantReminders[index].isChecked.toggle()
            savePlants()
        }
    }
    
    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plantReminders) {
            UserDefaults.standard.set(encoded, forKey: "SavedPlants")
        }
    }
    
    func loadPlants() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedPlants"),
           let decoded = try? JSONDecoder().decode([PlantReminder].self, from: savedData) {
            plantReminders = decoded
        }
    }
    
    func resetAllChecks() {
        for index in plantReminders.indices {
            plantReminders[index].isChecked = false
        }
        savePlants()
    }
}

