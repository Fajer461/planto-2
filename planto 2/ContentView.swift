//
//  ContentView.swift
//  planto 2
//
//  Created by Fajer saleh on 04/05/1447 AH.
// Welcome Content Component
// Welcome Content Component
// MARK: - Welcome Content Component
import SwiftUI

// 🔹 امتداد لدعم ألوان HEX
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // تجاهل #
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct FirstView: View {
    
    @StateObject private var viewModel = FirstViewModel()
    
    var body: some View {
        
        ZStack {
            
            // MARK: - Background color
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Show the main view
            if viewModel.showMainView {
                MainView(viewModel: viewModel.plantViewModel)
                    .transition(.opacity)
                    .zIndex(0)
            }
            
            // Show the welcome screen
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

// MARK: - Welcome Content Component
struct WelcomeContentView: View {
    let onSetReminder: () -> Void
    
    var body: some View {
        VStack {
            // MARK: - Title on top left
            VStack(alignment: .leading, spacing: 22) {
                Text("My Plants 🌱")
                    .font(.system(size: 43, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 400, height: 0.40) // الخط تحت الكلمة
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 25)
            .padding(.top, 60)
            
            Spacer()
            
            // MARK: - Plant Illustration
            Image("plant1")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 200)
                .padding()
            
            // Title
            Text("Start your plant journey!")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 0)
            
            // Subtitle
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
                    .foregroundColor(.white) // النص أبيض كما طلبتِ
                    .frame(width: 280, height: 40)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#66FED0"), Color(hex: "#66FED0").opacity(0.8)], // ✅ الخلفية باللون الجديد فقط
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color(hex: "#66FED0").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    FirstView()
}
