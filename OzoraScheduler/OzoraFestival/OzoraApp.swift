import SwiftUI

@main
struct OzoraApp: App {
    // Initialize our data manager early so it's ready by the time the UI loads
    @StateObject private var dataManager = DataManager()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(favoritesManager)
                .preferredColorScheme(.dark) // Force dark mode as per requirements
                .accentColor(Color.ozHighlight)
        }
    }
}
