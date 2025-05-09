import Foundation

struct Performance: Identifiable, Codable, Hashable {
    var id = UUID()
    let artistName: String
    let stageName: String
    let date: Date
    let startTime: Date
    let endTime: Date
    
    // Helper properties
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }
    
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endTime)
    }
    
    var timeRangeString: String {
        "\(startTimeString) - \(endTimeString)"
    }
    
    // Function to check if performance is currently playing
    func isPlaying(at time: Date = Date()) -> Bool {
        return time >= startTime && time <= endTime
    }
    
    // Function to check if performance is on a given day
    func isOnDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self.date, inSameDayAs: date)
    }
    
    // CodingKeys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case artistName = "artista"
        case stageName = "palco"
        case date = "dia"
        case startTime = "inicio"
        case endTime = "fim"
        case id
    }
}
