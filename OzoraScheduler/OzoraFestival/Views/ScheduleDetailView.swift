import SwiftUI

struct ScheduleDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scheduleManager: CustomScheduleManager
    @EnvironmentObject var dataManager: DataManager
    
    let schedule: CustomSchedule
    @State private var selectedDate: Date? = nil
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteConfirmation = false
    @State private var conflicts: [Performance: [Performance]] = [:]
    
    private var performancesByDay: [Date: [Performance]] {
        return schedule.performancesByDay()
    }
    
    private var sortedDays: [Date] {
        return performancesByDay.keys.sorted()
    }
    
    private var filteredPerformances: [Performance] {
        if let date = selectedDate {
            return schedule.performancesOnDay(date)
        } else if !sortedDays.isEmpty {
            return schedule.performancesOnDay(sortedDays[0])
        }
        return []
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
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
                    // Schedule stats
                    VStack(spacing: 10) {
                        Text(schedule.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            StatItem(value: "\(schedule.totalArtists)", label: "Artists")
                            StatItem(value: "\(schedule.totalDays)", label: "Days")
                            StatItem(value: String(format: "%.1f", schedule.totalHours), label: "Hours")
                        }
                        .padding(.vertical)
                        
                        if !conflicts.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(conflicts.count) scheduling conflicts detected")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    // Day selector
                    if !sortedDays.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(sortedDays, id: \.self) { date in
                                    Button(action: {
                                        selectedDate = date
                                    }) {
                                        Text(formatDate(date))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                (selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date)) ||
                                                (selectedDate == nil && sortedDays[0] == date)
                                                ? Color.ozHighlight 
                                                : Color.black.opacity(0.3)
                                            )
                                            .foregroundColor(
                                                (selectedDate != nil && Calendar.current.isDate(selectedDate!, inSameDayAs: date)) ||
                                                (selectedDate == nil && sortedDays[0] == date)
                                                ? .black 
                                                : .white
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Performances list
                        List {
                            let groupedByStage = Dictionary(grouping: filteredPerformances) { $0.stageName }
                            
                            ForEach(groupedByStage.keys.sorted(), id: \.self) { stageName in
                                if let stagePerformances = groupedByStage[stageName]?.sorted(by: { $0.startTime < $1.startTime }) {
                                    Section(header: 
                                        Text(stageName)
                                            .font(.headline)
                                            .foregroundColor(Stage(name: stageName, performances: []).color)
                                            .textCase(nil)
                                    ) {
                                        ForEach(stagePerformances) { performance in
                                            SchedulePerformanceRow(
                                                performance: performance,
                                                hasConflict: conflicts.keys.contains { $0.id == performance.id }
                                            )
                                        }
                                        .onDelete { indexSet in
                                            for index in indexSet {
                                                scheduleManager.removePerformance(
                                                    scheduleId: schedule.id,
                                                    performanceId: stagePerformances[index].id
                                                )
                                                // Update conflicts
                                                if let updatedSchedule = scheduleManager.customSchedules.first(where: { $0.id == schedule.id }) {
                                                    conflicts = scheduleManager.findConflicts(in: updatedSchedule)
                                                }
                                            }
                                        }
                                    }
                                    .listRowBackground(Color.ozBackground)
                                }
                            }
                        }
                        .listStyle(GroupedListStyle())
                    } else {
                        Spacer()
                        Text("No performances in this schedule")
                            .foregroundColor(.ozSecondary)
                        Spacer()
                    }
                }
                .navigationBarItems(
                    leading: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: HStack {
                        Button(action: {
                            isShowingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            isShowingDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                )
                .sheet(isPresented: $isShowingEditSheet) {
                    EditScheduleView(schedule: schedule)
                        .environmentObject(scheduleManager)
                        .environmentObject(dataManager)
                }
                .alert(isPresented: $isShowingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Schedule"),
                        message: Text("Are you sure you want to delete '\(schedule.name)'? This cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            scheduleManager.deleteSchedule(id: schedule.id)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .onAppear {
            // Find any scheduling conflicts
            conflicts = scheduleManager.findConflicts(in: schedule)
            
            // Set initial selected date if empty
            if selectedDate == nil && !sortedDays.isEmpty {
                selectedDate = sortedDays[0]
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.ozHighlight)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.ozSecondary)
        }
        .frame(minWidth: 60)
    }
}

struct SchedulePerformanceRow: View {
    let performance: Performance
    let hasConflict: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if hasConflict {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                Text(performance.artistName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            HStack {
                Text(performance.timeRangeString)
                    .font(.subheadline)
                    .foregroundColor(.ozSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EditScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scheduleManager: CustomScheduleManager
    @EnvironmentObject var dataManager: DataManager
    
    let schedule: CustomSchedule
    @State private var scheduleName: String
    
    init(schedule: CustomSchedule) {
        self.schedule = schedule
        self._scheduleName = State(initialValue: schedule.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    TextField("Schedule Name", text: $scheduleName)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Spacer()
                }
                .navigationTitle("Edit Schedule")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        saveSchedule()
                    }
                    .disabled(scheduleName.isEmpty)
                )
            }
        }
    }
    
    private func saveSchedule() {
        // Create updated schedule
        var updatedSchedule = schedule
        updatedSchedule.name = scheduleName
        
        // Update the schedule
        scheduleManager.updateSchedule(updatedSchedule)
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

struct ScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let performances = [Performance(
            artistName: "Test Artist",
            stageName: "Test Stage",
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )]
        
        let schedule = CustomSchedule(
            name: "Test Schedule",
            performances: performances,
            createdAt: Date()
        )
        
        return ScheduleDetailView(schedule: schedule)
            .environmentObject(CustomScheduleManager())
            .environmentObject(DataManager())
            .preferredColorScheme(.dark)
    }
}