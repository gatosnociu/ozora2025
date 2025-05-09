import Foundation
import Combine

class TimeManager: ObservableObject {
    @Published var currentDate = Date()
    private var timer: Timer?
    
    init() {
        // Update time every minute
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // Calculate time until festival starts
    func timeUntilFestival(festivalStart: Date) -> (days: Int, hours: Int, minutes: Int)? {
        let now = Date()
        
        // If festival has already started, return nil
        if now >= festivalStart {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: festivalStart)
        
        guard let days = components.day,
              let hours = components.hour,
              let minutes = components.minute else {
            return nil
        }
        
        return (days, hours, minutes)
    }
    
    // Format a countdown string
    func formatCountdown(days: Int, hours: Int, minutes: Int) -> String {
        return "\(days) days, \(hours) hours, \(minutes) minutes"
    }
    
    // Check if date is within festival period
    func isWithinFestival(start: Date, end: Date) -> Bool {
        let now = currentDate
        return now >= start && now <= end
    }
    
    // Get a formatted string for the current day of festival
    func festivalDayString(festivalStart: Date) -> String {
        let now = currentDate
        let calendar = Calendar.current
        
        if let days = calendar.dateComponents([.day], from: festivalStart, to: now).day, days >= 0 {
            return "Day \(days + 1)"
        } else {
            return "Coming Soon"
        }
    }
}
