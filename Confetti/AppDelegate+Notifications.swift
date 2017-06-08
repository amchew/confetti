import Foundation
import UserNotifications

import ConfettiKit

extension AppDelegate {
    
    func notifications(for event: Event) -> [UNNotificationRequest] {
        let viewModel = EventViewModel.fromEvent(event)
        let baseDate = viewModel.nextOccurrence
        
        let calendar = Calendar.current
        
        return viewModel.notifications.map { spec in
            let content = UNMutableNotificationContent()
            content.title = spec.title
            content.body = spec.message
            content.sound = UNNotificationSound.default()
            
            let date = calendar.date(byAdding: .day, value: -spec.daysBefore, to: baseDate)!
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(
                    month: calendar.component(.month, from: date),
                    day: calendar.component(.day, from: date),
                    hour: 9
                ),
                repeats: false
            )
            
            let identifier = (viewModel.event.key ?? "") + spec.id
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            return request
        }
    }
    
    func scheduleNotifications(for events: [Event]) {
        let center = UNUserNotificationCenter.current()
        
        let notifications = events.flatMap { self.notifications(for: $0) }
        for notification in notifications {
            center.add(notification) { error in
                if error != nil {
                    // Handle any errors
                }
            }
        }
    }
    
    func scheduleSampleNotification() {
        // Let send a sample notification
        let notes = UserViewModel.current.events!.flatMap { notifications(for: $0) }
        let randi = Int(arc4random_uniform(UInt32(notes.count)))
        
        let request = notes[randi]
        let when = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(timeIntervalSinceNow: 1))
        let newRequest = UNNotificationRequest(
            identifier: "rando",
            content: request.content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: when,
                repeats: false
            )
        )
        UNUserNotificationCenter.current().add(newRequest)
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        withCompletionHandler(UNNotificationPresentationOptions.sound)
    }
    
    // TODO: Handle what happens when user swipes on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // The user dismissed the notification without taking action
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // The user launched the app
        }
        
        // Else handle any custom actions. . .
    }
}
