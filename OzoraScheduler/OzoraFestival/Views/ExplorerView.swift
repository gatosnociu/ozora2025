import SwiftUI

struct ExplorerView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedDate: Date
    @State private var showFavoritesOnly = false
    @State private var selectedHour: Double = 12 // Default to noon
    
    // Festival dates
    private let festivalDates: [Date]
    
    init() {
        // Create dates for July 28 - August 3, 2025
        let calendar = Calendar.current
        var dates: [Date] = []
        
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 7
        dateComponents.day = 28
        
        if let startDate = calendar.date(from: dateComponents) {
            var currentDate = startDate
            
            for _ in 0..<7 { // 7 days
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        self.festivalDates = dates
        self._selectedDate = State(initialValue: dates.first ?? Date())
    }
    
    private var filteredPerformances: [Performance] {
        var performances = dataManager.performancesForDay(date: selectedDate)
        
        // Filter by hour
        let selectedHourInt = Int(selectedHour)
        performances = performances.filter { performance in
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: performance.startTime)
            return hour == selectedHourInt || 
                  (performance.isPlaying(at: hourDate(selectedHourInt)))
        }
        
        // Filter by favorites if needed
        if showFavoritesOnly {
            performances = performances.filter { 
                favoritesManager.isFavorite($0.artistName)
            }
        }
        
        return performances
    }
    
    private func hourDate(_ hour: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? selectedDate
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if dataManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ozHighlight))
                    } else {
                        // Date selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(festivalDates, id: \.self) { date in
                                    Button(action: {
                                        selectedDate = date
                                    }) {
                                        VStack {
                                            Text(formattedDate(date))
                                                .font(.caption)
                                                .foregroundColor(
                                                    Calendar.current.isDate(selectedDate, inSameDayAs: date) 
                                                    ? .ozHighlight 
                                                    : .white
                                                )
                                            
                                            if Calendar.current.isDate(selectedDate, inSameDayAs: date) {
                                                Rectangle()
                                                    .frame(height: 2)
                                                    .foregroundColor(.ozHighlight)
                                            } else {
                                                Rectangle()
                                                    .frame(height: 2)
                                                    .foregroundColor(.clear)
                                            }
                                        }
                                        .padding(.horizontal, 5)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                        
                        // Hour selector and favorites toggle
                        VStack {
                            HStack {
                                Text("Hour: \(Int(selectedHour)):00")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showFavoritesOnly.toggle()
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                        Text("Favorites")
                                    }
                                    .foregroundColor(showFavoritesOnly ? .ozHighlight : .ozSecondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            Slider(value: $selectedHour, in: 0...23, step: 1)
                                .accentColor(.ozHighlight)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                        
                        // Performances
                        if filteredPerformances.isEmpty {
                            Spacer()
                            Text("No performances at this time")
                                .foregroundColor(.ozSecondary)
                            Spacer()
                        } else {
                            List {
                                // Group by stage
                                let groupedByStage = Dictionary(grouping: filteredPerformances) { $0.stageName }
                                
                                ForEach(groupedByStage.keys.sorted(), id: \.self) { stageName in
                                    if let performances = groupedByStage[stageName] {
                                        Section(header: 
                                            Text(stageName)
                                                .font(.headline)
                                                .foregroundColor(Stage(name: stageName, performances: []).color)
                                                .textCase(nil)
                                        ) {
                                            ForEach(performances.sorted { $0.startTime < $1.startTime }) { performance in
                                                ArtistRow(artist: Artist(name: performance.artistName, performances: [performance]))
                                            }
                                        }
                                        .listRowBackground(Color.ozBackground)
                                    }
                                }
                            }
                            .listStyle(GroupedListStyle())
                        }
                    }
                }
                .navigationTitle("Explore")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct ExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        ExplorerView()
            .environmentObject(DataManager())
            .environmentObject(FavoritesManager())
            .preferredColorScheme(.dark)
    }
}
