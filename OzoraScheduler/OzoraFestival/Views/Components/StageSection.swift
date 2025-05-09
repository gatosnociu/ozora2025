import SwiftUI

struct StageSection: View {
    let stage: Stage
    let date: Date
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    private var performancesForDay: [Performance] {
        return stage.performancesOnDay(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(stage.name)
                .font(.headline)
                .foregroundColor(stage.color)
                .padding(.bottom, 5)
            
            if performancesForDay.isEmpty {
                Text("No performances scheduled")
                    .font(.caption)
                    .foregroundColor(.ozSecondary)
                    .padding(.vertical, 5)
            } else {
                ForEach(performancesForDay) { performance in
                    HStack {
                        Text(performance.startTimeString)
                            .font(.subheadline)
                            .foregroundColor(.ozSecondary)
                            .frame(width: 50, alignment: .leading)
                        
                        Text(performance.artistName)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            favoritesManager.toggleFavorite(artistName: performance.artistName)
                        }) {
                            Image(systemName: 
                                    favoritesManager.isFavorite(artistName: performance.artistName) 
                                  ? "star.fill" 
                                  : "star")
                                .foregroundColor(
                                    favoritesManager.isFavorite(artistName: performance.artistName) 
                                    ? .ozHighlight 
                                    : .ozSecondary)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    Divider()
                        .background(Color.ozSecondary.opacity(0.3))
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}
