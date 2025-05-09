import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var timeManager = TimeManager()
    @State private var selectedStage: String? = nil
    
    private var currentlyPlaying: [Performance] {
        let now = Date()
        return dataManager.performances.filter { $0.isPlaying(at: now) }
    }
    
    private var stagesWithPerformances: [String] {
        return Array(Set(currentlyPlaying.map { $0.stageName })).sorted()
    }
    
    private var filteredPerformances: [Performance] {
        if let stage = selectedStage {
            return currentlyPlaying.filter { $0.stageName == stage }
        }
        return currentlyPlaying
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if dataManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ozHighlight))
                    } else if !dataManager.isFestivalActive() {
                        CountdownView(
                            festivalStart: dataManager.festivalStartDate,
                            festivalEnd: dataManager.festivalEndDate
                        )
                    } else if currentlyPlaying.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 70))
                                .foregroundColor(.ozHighlight.opacity(0.8))
                            
                            Text("No performances right now")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Check back later for upcoming sets")
                                .font(.subheadline)
                                .foregroundColor(.ozSecondary)
                        }
                        .padding()
                    } else {
                        // Stage filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button(action: {
                                    selectedStage = nil
                                }) {
                                    Text("All Stages")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedStage == nil ? Color.ozHighlight : Color.black.opacity(0.3))
                                        .foregroundColor(selectedStage == nil ? .black : .white)
                                        .cornerRadius(8)
                                }
                                
                                ForEach(stagesWithPerformances, id: \.self) { stage in
                                    Button(action: {
                                        selectedStage = stage
                                    }) {
                                        Text(stage)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedStage == stage ? Color.ozHighlight : Color.black.opacity(0.3))
                                            .foregroundColor(selectedStage == stage ? .black : .white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Performance list
                        List {
                            ForEach(filteredPerformances) { performance in
                                VStack(alignment: .leading, spacing: 8) {
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
                                .padding(.vertical, 6)
                                .listRowBackground(Color.ozBackground)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Now Playing")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onReceive(timeManager.$currentDate) { _ in
            // This will refresh the view every minute
        }
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView()
            .environmentObject(DataManager())
            .preferredColorScheme(.dark)
    }
}
