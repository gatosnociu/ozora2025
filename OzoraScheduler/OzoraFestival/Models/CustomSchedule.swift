import Foundation

struct CustomSchedule: Identifiable, Codable {
    var id = UUID()
    var name: String
    var performances: [Performance]
    var createdAt: Date
    
    // Helper function to get performances grouped by day
    func performancesByDay() -> [Date: [Performance]] {
        let calendar = Calendar.current
        var result: [Date: [Performance]] = [:]
        
        // Group performances by day
        for performance in performances.sorted(by: { $0.startTime < $1.startTime }) {
            // Get the day component only
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: performance.date)
            if let date = calendar.date(from: dateComponents) {
                if result[date] == nil {
                    result[date] = []
                }
                result[date]?.append(performance)
            }
        }
        
        return result
    }
    
    // Helper function to check if schedule has any performances on a specific day
    func hasPerformancesOnDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return performances.contains { performance in
            calendar.isDate(performance.date, inSameDayAs: date)
        }
    }
    
    // Helper function to get all performances on a specific day
    func performancesOnDay(_ date: Date) -> [Performance] {
        let calendar = Calendar.current
        return performances.filter { performance in
            calendar.isDate(performance.date, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // Get summary statistics
    var totalDays: Int {
        return Set(performances.map { Calendar.current.startOfDay(for: $0.date) }).count
    }
    
    var totalArtists: Int {
        return Set(performances.map { $0.artistName }).count
    }
    
    var totalHours: Double {
        var total = 0.0
        for performance in performances {
            let duration = performance.endTime.timeIntervalSince(performance.startTime)
            total += duration / 3600 // Convert to hours
        }
        return total
    }
}