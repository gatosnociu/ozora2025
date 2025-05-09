import Foundation

struct Stage: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    var performances: [Performance]
    
    // Sort performances by date and time
    var sortedPerformances: [Performance] {
        return performances.sorted { 
            if $0.date == $1.date {
                return $0.startTime < $1.startTime
            }
            return $0.date < $1.date
        }
    }
    
    // Get performances for a specific date
    func performancesOnDay(_ date: Date) -> [Performance] {
        return performances.filter { performance in
            let calendar = Calendar.current
            return calendar.isDate(performance.date, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // Get current/next performance
    func currentOrNextPerformance(at time: Date = Date()) -> Performance? {
        // First, try to find a currently playing performance
        if let current = performances.first(where: { $0.isPlaying(at: time) }) {
            return current
        }
        
        // If none playing now, find the next scheduled performance
        return performances
            .filter { $0.startTime > time }
            .sorted { $0.startTime < $1.startTime }
            .first
    }
}
