//
//  ContentView.swift
//  planto 2
//
//  Created by Fajer saleh on 04/05/1447 AH.
import SwiftUI


struct FirstView: View {
    
    @StateObject private var viewModel = FirstViewModel()
    
    var body: some View {
        
        ZStack {
            
        
//           to show the mainView
            if viewModel.showMainView {
                
                MainView(viewModel: viewModel.plantViewModel)
                    .transition(.opacity)
                    .zIndex(0)
            }
            
//            to show the welcome screen
            if !viewModel.showMainView && !viewModel.showReminderSheet {
                WelcomeContentView(
                    onSetReminder: {
                        viewModel.openReminderSheet()
                    }
                )
                .transition(.opacity)
                .zIndex(1)
            }
            
            
            // Reminder Sheet
            if viewModel.showReminderSheet {
                PlantReminderSheet(
                    isPresented: $viewModel.showReminderSheet
                ) { newPlant in
                    viewModel.savePlantAndNavigate(newPlant)
                }
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showReminderSheet)
        .animation(.easeInOut(duration: 0.4), value: viewModel.showMainView)
    }
}

// Welcome Content Component
struct WelcomeContentView: View {
    let onSetReminder: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: - Plant Illustration
            Image("plant1")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 200)
                .padding()
            
            //  Title
            Text("Start your plant journey!")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 0)
            
            //  Subtitle
            Text("Now all your plants will be in one place and\nwe will help you take care of them :) 🪴")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
            
            // Button
            Button(action: onSetReminder) {
                Text("Set Plant Reminder")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 280, height: 40)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Preview
#Preview {
    FirstView()
}

