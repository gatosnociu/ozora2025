import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteArtists: Set<String> = []
    
    // Key for storing in UserDefaults
    private let favoritesKey = "ozora.favoriteArtists"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let favoritesData = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode(Set<String>.self, from: favoritesData) {
                self.favoriteArtists = decoded
            }
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteArtists) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(artistName: String) {
        if favoriteArtists.contains(artistName) {
            favoriteArtists.remove(artistName)
        } else {
            favoriteArtists.insert(artistName)
        }
        saveFavorites()
    }
    
    func isFavorite(artistName: String) -> Bool {
        return favoriteArtists.contains(artistName)
    }
    
    // Get all favorite performances
    func favoritePerformances(from allPerformances: [Performance]) -> [Performance] {
        return allPerformances.filter { favoriteArtists.contains($0.artistName) }
    }
}
