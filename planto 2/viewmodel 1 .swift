//
//  viewmodel 1 .swift
//  planto 2
//
//  Created by Fajer saleh on 04/05/1447 AH.
//
import Foundation
import SwiftUI
import UserNotifications
internal import Combine

// MARK: - First View Model
class FirstViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showReminderSheet: Bool = false
    @Published var showMainView: Bool = false
    @Published var plantViewModel: PlantReminderViewModel
    
    // MARK: - Initializer
    init() {
        self.plantViewModel = PlantReminderViewModel()
        requestNotificationPermission() // نطلب الإذن عند تشغيل التطبيق أول مرة
    }
    
    // MARK: - Actions
    
    // Opens the reminder sheet with smooth slide up
    func openReminderSheet() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showReminderSheet = true
        }
    }
    
    // Closes the sheet without saving
    func closeReminderSheet() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showReminderSheet = false
        }
    }
    
    // Saves plant and transitions to MainView smoothly
    func savePlantAndNavigate(_ plant: PlantReminder) {
        // Add plant to ViewModel
        plantViewModel.addPlant(plant)
        
        // إرسال إشعار بعد 3 ثواني من حفظ النبات
        scheduleNotification()
        
        // Smooth transition sequence:
        // 1. Start showing MainView behind the sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showMainView = true
            }
        }
        
        // 2. Slide the sheet down
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                self.showReminderSheet = false
            }
        }
    }
    
    // Reset navigation state
    func resetNavigation() {
        showMainView = false
        showReminderSheet = false
    }
    
    // MARK: - Notifications
    
    /// طلب إذن الإشعارات من المستخدم
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notification permission granted" : "⚠️ Notification permission denied")
            }
        }
    }
    
    /// جدولة إشعار بعد 3 ثواني
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let’s water your plant 🌱"
        content.sound = UNNotificationSound.default
        
        // بعد 3 ثواني من الآن
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully")
            }
        }
    }
}
