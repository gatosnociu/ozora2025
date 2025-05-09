import SwiftUI

struct ArtistRow: View {
    let artist: Artist
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(artist.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    favoritesManager.toggleFavorite(artistName: artist.name)
                }) {
                    Image(systemName: favoritesManager.isFavorite(artistName: artist.name) ? "star.fill" : "star")
                        .foregroundColor(favoritesManager.isFavorite(artistName: artist.name) ? .ozHighlight : .ozSecondary)
                }
            }
            
            // Show performance details if available
            if !artist.performances.isEmpty {
                ForEach(artist.performances.sorted { $0.startTime < $1.startTime }.prefix(3)) { performance in
                    HStack {
                        Text(performance.stageName)
                            .font(.subheadline)
                            .foregroundColor(Stage(name: performance.stageName, performances: []).color)
                        
                        Spacer()
                        
                        Text("\(performance.dayString) • \(performance.timeRangeString)")
                            .font(.caption)
                            .foregroundColor(.ozSecondary)
                    }
                }
                
                // If there are more than 3 performances, show a message
                if artist.performances.count > 3 {
                    Text("+ \(artist.performances.count - 3) more performances")
                        .font(.caption)
                        .foregroundColor(.ozSecondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
