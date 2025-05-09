import SwiftUI

struct CreateScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scheduleManager: CustomScheduleManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var scheduleName = ""
    @State private var selectedPerformances: Set<UUID> = []
    @State private var searchQuery = ""
    @State private var showFavoritesOnly = false
    @State private var selectedDay: Date? = nil
    
    private var festivalDates: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        var currentDate = dataManager.festivalStartDate
        while currentDate <= dataManager.festivalEndDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private var filteredPerformances: [Performance] {
        var performances = dataManager.performances
        
        // Filter by day if selected
        if let day = selectedDay {
            performances = performances.filter { performance in
                let calendar = Calendar.current
                return calendar.isDate(performance.date, inSameDayAs: day)
            }
        }
        
        // Filter by search query
        if !searchQuery.isEmpty {
            performances = performances.filter { $0.artistName.localizedCaseInsensitiveContains(searchQuery) }
        }
        
        // Filter by favorites if enabled
        if showFavoritesOnly {
            performances = performances.filter { favoritesManager.isFavorite(artistName: $0.artistName) }
        }
        
        // Sort by time and stage
        return performances.sorted { 
            if $0.date == $1.date {
                if $0.startTime == $1.startTime {
                    return $0.stageName < $1.stageName
                }
                return $0.startTime < $1.startTime
            }
            return $0.date < $1.date
        }
    }
    
    private var groupedPerformances: [String: [Performance]] {
        Dictionary(grouping: filteredPerformances) { performance in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            return dateFormatter.string(from: performance.date)
        }
    }
    
    private var sortedDays: [String] {
        groupedPerformances.keys.sorted { day1, day2 in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            guard let date1 = dateFormatter.date(from: day1),
                  let date2 = dateFormatter.date(from: day2) else {
                return day1 < day2
            }
            return date1 < date2
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Schedule name input
                    TextField("Schedule Name", text: $scheduleName)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Search and filter section
                    VStack {
                        // Search field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.ozSecondary)
                            
                            TextField("Search artists...", text: $searchQuery)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        
                        // Filter options
                        HStack {
                            // Day filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    Button(action: {
                                        selectedDay = nil
                                    }) {
                                        Text("All Days")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedDay == nil ? Color.ozHighlight : Color.black.opacity(0.3))
                                            .foregroundColor(selectedDay == nil ? .black : .white)
                                            .cornerRadius(8)
                                    }
                                    
                                    ForEach(festivalDates, id: \.self) { date in
                                        Button(action: {
                                            selectedDay = date
                                        }) {
                                            Text(formatDate(date))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedDay != nil && Calendar.current.isDate(selectedDay!, inSameDayAs: date) 
                                                    ? Color.ozHighlight 
                                                    : Color.black.opacity(0.3)
                                                )
                                                .foregroundColor(
                                                    selectedDay != nil && Calendar.current.isDate(selectedDay!, inSameDayAs: date)
                                                    ? .black 
                                                    : .white
                                                )
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Favorites toggle
                            Button(action: {
                                showFavoritesOnly.toggle()
                            }) {
                                Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                    .foregroundColor(showFavoritesOnly ? .ozHighlight : .ozSecondary)
                                    .padding(10)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Selected count
                    HStack {
                        Text("\(selectedPerformances.count) performances selected")
                            .font(.caption)
                            .foregroundColor(.ozSecondary)
                        
                        Spacer()
                        
                        if !selectedPerformances.isEmpty {
                            Button(action: {
                                selectedPerformances.removeAll()
                            }) {
                                Text("Clear")
                                    .font(.caption)
                                    .foregroundColor(.ozHighlight)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    // Performance list
                    List {
                        ForEach(sortedDays, id: \.self) { day in
                            Section(header: Text(day).foregroundColor(.ozHighlight).textCase(nil)) {
                                ForEach(groupedPerformances[day] ?? []) { performance in
                                    PerformanceSelectionRow(
                                        performance: performance,
                                        isSelected: selectedPerformances.contains(performance.id),
                                        onToggle: { isSelected in
                                            if isSelected {
                                                selectedPerformances.insert(performance.id)
                                            } else {
                                                selectedPerformances.remove(performance.id)
                                            }
                                        }
                                    )
                                    .listRowBackground(Color.ozBackground)
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
                .navigationTitle("Create Schedule")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        saveSchedule()
                    }
                    .disabled(scheduleName.isEmpty || selectedPerformances.isEmpty)
                    .opacity(scheduleName.isEmpty || selectedPerformances.isEmpty ? 0.5 : 1)
                )
            }
        }
    }
    
    private func saveSchedule() {
        // Get the selected performances
        let performances = dataManager.performances.filter { selectedPerformances.contains($0.id) }
        
        // Create the schedule
        _ = scheduleManager.createSchedule(name: scheduleName, performances: performances)
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

struct PerformanceSelectionRow: View {
    let performance: Performance
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(performance.artistName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(performance.stageName)
                        .font(.subheadline)
                        .foregroundColor(Stage(name: performance.stageName, performances: []).color)
                    
                    Spacer()
                    
                    Text(performance.timeRangeString)
                        .font(.caption)
                        .foregroundColor(.ozSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .ozHighlight : .ozSecondary)
                .font(.system(size: 20))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle(!isSelected)
        }
        .padding(.vertical, 4)
    }
}

struct CreateScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        CreateScheduleView()
            .environmentObject(CustomScheduleManager())
            .environmentObject(DataManager())
            .environmentObject(FavoritesManager())
            .preferredColorScheme(.dark)
    }
}