import Foundation

struct Artist: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    var performances: [Performance]
    
    // Helper property to get all stages an artist performs at
    var stages: [String] {
        return Array(Set(performances.map { $0.stageName })).sorted()
    }
    
    // Helper property to get all dates an artist performs
    var dates: [Date] {
        return Array(Set(performances.map { $0.date })).sorted()
    }
    
    // Helper function to check if artist is currently playing
    func isCurrentlyPlaying(at time: Date = Date()) -> Bool {
        return performances.contains { $0.isPlaying(at: time) }
    }
    
    // Helper function to get currently playing performance if any
    func currentPerformance(at time: Date = Date()) -> Performance? {
        return performances.first { $0.isPlaying(at: time) }
    }
}
