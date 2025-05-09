import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab = 0
    @StateObject private var scheduleManager = CustomScheduleManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
            NowPlayingView()
                .tabItem {
                    Label("Now", systemImage: "music.note")
                }
                .tag(1)
            
            ExplorerView()
                .tabItem {
                    Label("Explore", systemImage: "calendar")
                }
                .tag(2)
            
            MyScheduleView()
                .environmentObject(scheduleManager)
                .tabItem {
                    Label("My Schedule", systemImage: "star.circle")
                }
                .tag(3)
        }
        .accentColor(Color.ozHighlight)
        .onAppear {
            // Load data when app first appears
            dataManager.loadData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
            .environmentObject(FavoritesManager())
            .preferredColorScheme(.dark)
    }
}
