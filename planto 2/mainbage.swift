//
//  mainbage.swift
//  planto 2
//
//  Created by Fajer saleh on 04/05/1447 AH.
//
import SwiftUI

// MARK: - Main View
struct MainView: View {
    @ObservedObject var viewModel: PlantReminderViewModel
    @State private var showAddSheet = false
    @State private var selectedPlant: PlantReminder? = nil
    
    // Check if all plants are watered (checked)
    var allPlantsCompleted: Bool {
        !viewModel.plantReminders.isEmpty &&
        viewModel.plantReminders.allSatisfy { $0.isChecked }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("My Plants")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Text("🌱")
                        .font(.system(size: 34))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // MARK: - Content Switcher
                if allPlantsCompleted {
                    // MARK: - All Done Screen
                    AllDoneView()
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // MARK: - Normal Plant List View
                    VStack(spacing: 0) {
                        // Progress Banner
                        VStack(spacing: 12) {
                            Text("Your plants are waiting for a sip 💧")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: UIScreen.main.bounds.width * 0.9 * viewModel.progressPercentage, height: 4)
                                    .animation(.spring(), value: viewModel.progressPercentage)
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Plant List
                        List {
                            ForEach(viewModel.plantReminders) { reminder in
                                PlantReminderRow(
                                    reminder: reminder,
                                    onToggle: {
                                        withAnimation(.spring()) {
                                            viewModel.toggleCheck(for: reminder)
                                        }
                                    },
                                    onTap: {
                                        selectedPlant = reminder
                                    }
                                )
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.deletePlant(reminder)
                                        }
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 20))
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
            
            // MARK: - Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: allPlantsCompleted)
        // MARK: - Add New Plant Sheet
        .sheet(isPresented: $showAddSheet) {
            PlantReminderSheet(isPresented: $showAddSheet) { newPlant in
                withAnimation {
                    viewModel.addPlant(newPlant)
                }
            }
        }
        // MARK: - Edit Sheet
        .sheet(item: $selectedPlant) { plant in
            PlantReminderSheet(
                isPresented: Binding(
                    get: { selectedPlant != nil },
                    set: { if !$0 { selectedPlant = nil } }
                ),
                onSave: { updatedPlant in
                    withAnimation {
                        viewModel.updatePlant(updatedPlant)
                    }
                    selectedPlant = nil
                },
                onDelete: { plantToDelete in
                    withAnimation {
                        viewModel.deletePlant(plantToDelete)
                    }
                    selectedPlant = nil
                },
                existingPlant: plant
            )
        }
        .onAppear {
            viewModel.loadPlants()
        }
    }
}

// MARK: - All Done View Component
// Shows when all plants are checked/watered
struct AllDoneView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // MARK: - Happy Plant Image
            Image("plant2")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding()
            
            // MARK: - Completion Title
            Text("All Done! 🎉")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // MARK: - Completion Message
            Text("All Reminders Completed")
                .font(.system(size: 17))
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Plant Reminder Row
struct PlantReminderRow: View {
    let reminder: PlantReminder
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Checkbox
            Button(action: onToggle) {
                Circle()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(reminder.isChecked ? Color.green : Color.clear)
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(reminder.isChecked ? 1 : 0)
                    )
            }
            
            // MARK: - Plant Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("in \(reminder.room)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text(reminder.plantName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
//                        sunnn
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)

                        Text(reminder.lightCondition)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
//                        Waterrr
                        Image(systemName: "drop.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text(reminder.waterAmount)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }.foregroundColor(Color( "#CAF3FB"))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(white: 0.1))
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    MainView(viewModel: PlantReminderViewModel())
}
