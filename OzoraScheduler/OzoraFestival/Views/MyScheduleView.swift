import SwiftUI

struct MyScheduleView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var scheduleManager = CustomScheduleManager()
    @State private var isShowingCreateSheet = false
    @State private var selectedSchedule: CustomSchedule? = nil
    @State private var isShowingConfirmDelete = false
    @State private var scheduleToDelete: UUID? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if dataManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ozHighlight))
                    } else if scheduleManager.customSchedules.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 70))
                                .foregroundColor(.ozHighlight.opacity(0.8))
                            
                            Text("No custom schedules yet")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Create your own festival schedule by adding your favorite artists")
                                .font(.subheadline)
                                .foregroundColor(.ozSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                isShowingCreateSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Schedule")
                                }
                                .padding()
                                .background(Color.ozHighlight)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                            }
                            .padding(.top)
                            
                            Button(action: {
                                createScheduleFromFavorites()
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Create from Favorites")
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .foregroundColor(.ozHighlight)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.ozHighlight, lineWidth: 1)
                                )
                            }
                            .disabled(favoritesManager.favoriteArtists.isEmpty)
                            .opacity(favoritesManager.favoriteArtists.isEmpty ? 0.5 : 1)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(scheduleManager.customSchedules) { schedule in
                                Button(action: {
                                    selectedSchedule = schedule
                                }) {
                                    ScheduleRow(schedule: schedule)
                                }
                                .listRowBackground(Color.ozBackground)
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first {
                                    scheduleToDelete = scheduleManager.customSchedules[index].id
                                    isShowingConfirmDelete = true
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("My Schedules")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button(action: {
                        isShowingCreateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(dataManager.isLoading)
                )
                .sheet(isPresented: $isShowingCreateSheet) {
                    CreateScheduleView()
                        .environmentObject(scheduleManager)
                        .environmentObject(dataManager)
                }
                .sheet(item: $selectedSchedule) { schedule in
                    ScheduleDetailView(schedule: schedule)
                        .environmentObject(scheduleManager)
                        .environmentObject(dataManager)
                }
                .alert(isPresented: $isShowingConfirmDelete) {
                    Alert(
                        title: Text("Delete Schedule"),
                        message: Text("Are you sure you want to delete this schedule? This cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            if let id = scheduleToDelete {
                                scheduleManager.deleteSchedule(id: id)
                                scheduleToDelete = nil
                            }
                        },
                        secondaryButton: .cancel {
                            scheduleToDelete = nil
                        }
                    )
                }
            }
        }
    }
    
    private func createScheduleFromFavorites() {
        if let _ = scheduleManager.createFromFavorites(
            favoritesManager: favoritesManager,
            dataManager: dataManager
        ) {
            // Schedule created successfully
        }
    }
}

struct ScheduleRow: View {
    let schedule: CustomSchedule
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(schedule.totalArtists) artists • \(schedule.totalDays) days • \(String(format: "%.1f", schedule.totalHours)) hours")
                    .font(.caption)
                    .foregroundColor(.ozSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ozSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct MyScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        MyScheduleView()
            .environmentObject(DataManager())
            .environmentObject(FavoritesManager())
            .preferredColorScheme(.dark)
    }
}