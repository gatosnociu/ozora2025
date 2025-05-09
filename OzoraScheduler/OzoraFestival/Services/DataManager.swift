import Foundation
import Combine

class DataManager: ObservableObject {
    // Published properties for UI updates
    @Published var artists: [Artist] = []
    @Published var stages: [Stage] = []
    @Published var performances: [Performance] = []
    @Published var isLoading: Bool = true
    @Published var error: String? = nil
    
    // Festival date constants
    let festivalStartDate: Date
    let festivalEndDate: Date
    
    // Formatters
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    
    init() {
        // Set up festival dates
        let calendar = Calendar.current
        
        // Festival runs from July 28 to August 3, 2025
        var startComponents = DateComponents()
        startComponents.year = 2025
        startComponents.month = 7
        startComponents.day = 28
        startComponents.hour = 0
        startComponents.minute = 0
        self.festivalStartDate = calendar.date(from: startComponents)!
        
        var endComponents = DateComponents()
        endComponents.year = 2025
        endComponents.month = 8
        endComponents.day = 3
        endComponents.hour = 23
        endComponents.minute = 59
        self.festivalEndDate = calendar.date(from: endComponents)!
        
        // Initialize formatters
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
    }
    
    func loadData() {
        isLoading = true
        error = nil
        
        // In a real app, this would load from a bundled file
        if let path = Bundle.main.path(forResource: "timetables", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                
                // Custom date decoding
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Handle different date formats
                    if dateString.contains(":") {
                        // It's a time string (HH:MM)
                        guard let date = self.timeFormatter.date(from: dateString) else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Cannot decode time: \(dateString)"
                            )
                        }
                        return date
                    } else {
                        // It's a date string (YYYY-MM-DD)
                        guard let date = self.dateFormatter.date(from: dateString) else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Cannot decode date: \(dateString)"
                            )
                        }
                        return date
                    }
                }
                
                // Decode performances
                let decodedPerformances = try decoder.decode([Performance].self, from: data)
                self.performances = decodedPerformances
                
                // Process artists and stages
                processData(performances: decodedPerformances)
                
                isLoading = false
            } catch {
                self.error = "Error loading data: \(error.localizedDescription)"
                isLoading = false
            }
        } else {
            // Use mock data for development only
            createSampleData()
            isLoading = false
        }
    }
    
    private func processData(performances: [Performance]) {
        // Group by artist name
        let artistDict = Dictionary(grouping: performances) { $0.artistName }
        self.artists = artistDict.map { artistName, performances in
            Artist(name: artistName, performances: performances)
        }.sorted { $0.name < $1.name }
        
        // Group by stage name
        let stageDict = Dictionary(grouping: performances) { $0.stageName }
        self.stages = stageDict.map { stageName, performances in
            Stage(name: stageName, performances: performances)
        }.sorted { $0.name < $1.name }
    }
    
    // For development only - replaced by real data in production
    private func createSampleData() {
        // Create hard-coded sample data for each day of the festival
        let sampleStages = ["Dome Stage", "Dragons Nest", "Ozora", "Pumpui"]
        var allPerformances: [Performance] = []
        
        // Create 7 days of performances (July 28 - Aug 3, 2025)
        let calendar = Calendar.current
        var currentDate = festivalStartDate
        
        while currentDate <= festivalEndDate {
            for stageName in sampleStages {
                // Create 8 performances per day per stage
                for hour in stride(from: 12, to: 28, by: 2) { // 12pm to 4am
                    let actualHour = hour % 24
                    
                    // Create start time
                    var startTimeComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
                    startTimeComponents.hour = actualHour
                    startTimeComponents.minute = 0
                    let startTime = calendar.date(from: startTimeComponents)!
                    
                    // Create end time (2 hours later)
                    var endTimeComponents = startTimeComponents
                    endTimeComponents.hour = (actualHour + 2) % 24
                    let endTime = calendar.date(from: endTimeComponents)!
                    
                    // Artist name format: "Artist X - Stage Name"
                    let artistName = "Artist \(actualHour) - \(stageName)"
                    
                    let performance = Performance(
                        artistName: artistName,
                        stageName: stageName,
                        date: currentDate,
                        startTime: startTime,
                        endTime: endTime
                    )
                    
                    allPerformances.append(performance)
                }
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Set the performances and process them
        self.performances = allPerformances
        processData(performances: allPerformances)
    }
    
    // Search functionality
    func searchArtists(query: String) -> [Artist] {
        if query.isEmpty {
            return artists
        }
        
        return artists.filter { artist in
            artist.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    // Get performances currently playing
    func currentlyPlayingPerformances() -> [Performance] {
        let now = Date()
        return performances.filter { $0.isPlaying(at: now) }
    }
    
    // Get performances for a specific day
    func performancesForDay(date: Date) -> [Performance] {
        let calendar = Calendar.current
        return performances.filter { performance in
            calendar.isDate(performance.date, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    // Check if festival is currently active
    func isFestivalActive() -> Bool {
        let now = Date()
        return now >= festivalStartDate && now <= festivalEndDate
    }
}
