import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var searchQuery = ""
    @State private var showFavoritesOnly = false
    
    private var filteredArtists: [Artist] {
        var artists = dataManager.searchArtists(query: searchQuery)
        
        if showFavoritesOnly {
            artists = artists.filter { favoritesManager.isFavorite($0.name) }
        }
        
        return artists
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ozBackground.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        // Search bar
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
                    .padding(.horizontal)
                    
                    if dataManager.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ozHighlight))
                        Spacer()
                    } else if filteredArtists.isEmpty {
                        Spacer()
                        Text(searchQuery.isEmpty 
                             ? "No artists found in the lineup" 
                             : "No artists matching '\(searchQuery)'")
                            .foregroundColor(.ozSecondary)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredArtists) { artist in
                                ArtistRow(artist: artist)
                                    .listRowBackground(Color.ozBackground)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.ozBackground)
                    }
                }
                .navigationTitle("Artists")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(DataManager())
            .environmentObject(FavoritesManager())
            .preferredColorScheme(.dark)
    }
}
