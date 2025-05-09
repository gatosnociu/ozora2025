import Foundation
import Combine

class CustomScheduleManager: ObservableObject {
    @Published var customSchedules: [CustomSchedule] = []
    
    // Key for storing in UserDefaults
    private let schedulesKey = "ozora.customSchedules"
    
    init() {
        loadSchedules()
    }
    
    private func loadSchedules() {
        if let schedulesData = UserDefaults.standard.data(forKey: schedulesKey) {
            if let decoded = try? JSONDecoder().decode([CustomSchedule].self, from: schedulesData) {
                self.customSchedules = decoded
            }
        }
    }
    
    private func saveSchedules() {
        if let encoded = try? JSONEncoder().encode(customSchedules) {
            UserDefaults.standard.set(encoded, forKey: schedulesKey)
        }
    }
    
    // Create a new custom schedule
    func createSchedule(name: String, performances: [Performance] = []) -> CustomSchedule {
        let newSchedule = CustomSchedule(
            name: name,
            performances: performances,
            createdAt: Date()
        )
        
        customSchedules.append(newSchedule)
        saveSchedules()
        return newSchedule
    }
    
    // Delete a schedule
    func deleteSchedule(id: UUID) {
        customSchedules.removeAll { $0.id == id }
        saveSchedules()
    }
    
    // Update a schedule
    func updateSchedule(_ schedule: CustomSchedule) {
        if let index = customSchedules.firstIndex(where: { $0.id == schedule.id }) {
            customSchedules[index] = schedule
            saveSchedules()
        }
    }
    
    // Add performance to schedule
    func addPerformance(scheduleId: UUID, performance: Performance) {
        if let index = customSchedules.firstIndex(where: { $0.id == scheduleId }) {
            // Check if performance is already in the schedule
            if !customSchedules[index].performances.contains(where: { $0.id == performance.id }) {
                customSchedules[index].performances.append(performance)
                saveSchedules()
            }
        }
    }
    
    // Remove performance from schedule
    func removePerformance(scheduleId: UUID, performanceId: UUID) {
        if let index = customSchedules.firstIndex(where: { $0.id == scheduleId }) {
            customSchedules[index].performances.removeAll { $0.id == performanceId }
            saveSchedules()
        }
    }
    
    // Check if a performance is in a schedule
    func isPerformanceInSchedule(scheduleId: UUID, performanceId: UUID) -> Bool {
        guard let schedule = customSchedules.first(where: { $0.id == scheduleId }) else {
            return false
        }
        
        return schedule.performances.contains { $0.id == performanceId }
    }
    
    // Create schedule from favorites
    func createFromFavorites(favoritesManager: FavoritesManager, dataManager: DataManager) -> CustomSchedule? {
        let favoritePerformances = dataManager.performances.filter { 
            favoritesManager.isFavorite(artistName: $0.artistName) 
        }
        
        if favoritePerformances.isEmpty {
            return nil
        }
        
        return createSchedule(
            name: "My Favorites", 
            performances: favoritePerformances
        )
    }
    
    // Check for scheduling conflicts
    func findConflicts(in schedule: CustomSchedule) -> [Performance: [Performance]] {
        var conflicts: [Performance: [Performance]] = [:]
        
        for i in 0..<schedule.performances.count {
            let performance = schedule.performances[i]
            var performanceConflicts: [Performance] = []
            
            for j in 0..<schedule.performances.count where i != j {
                let otherPerformance = schedule.performances[j]
                
                // Check if performances overlap
                if performance.startTime < otherPerformance.endTime && 
                   performance.endTime > otherPerformance.startTime {
                    performanceConflicts.append(otherPerformance)
                }
            }
            
            if !performanceConflicts.isEmpty {
                conflicts[performance] = performanceConflicts
            }
        }
        
        return conflicts
    }
}