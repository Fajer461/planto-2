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
    
    func openReminderSheet() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showReminderSheet = true
        }
    }
    
    func closeReminderSheet() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showReminderSheet = false
        }
    }
    
    func savePlantAndNavigate(_ plant: PlantReminder) {
        plantViewModel.addPlant(plant)
        
        // إرسال إشعار متكرر كل 60 ثانية (آمن على iPhone)
        scheduleNotification()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showMainView = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                self.showReminderSheet = false
            }
        }
    }
    
    func resetNavigation() {
        showMainView = false
        showReminderSheet = false
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = NotificationDelegate.shared // مهم جداً
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print(granted ? "Notification permission granted ✅" : "Permission denied 🚫")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let’s water your plant 🌱"
        content.sound = UNNotificationSound.default
        
        // تكرار آمن على أجهزة iPhone
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "planto_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled ✅")
            }
        }
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // يضمن ظهور الإشعار حتى إذا التطبيق مفتوح
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
