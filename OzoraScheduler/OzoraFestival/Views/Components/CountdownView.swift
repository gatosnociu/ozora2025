import SwiftUI

struct CountdownView: View {
    let festivalStart: Date
    let festivalEnd: Date
    @StateObject private var timeManager = TimeManager()
    
    private var isFestivalOver: Bool {
        Date() > festivalEnd
    }
    
    private var countdown: (days: Int, hours: Int, minutes: Int)? {
        timeManager.timeUntilFestival(festivalStart: festivalStart)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(.ozHighlight)
                .padding(.bottom, 20)
            
            if isFestivalOver {
                Text("Ozora Festival 2025 has ended")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("See you next year!")
                    .font(.title2)
                    .foregroundColor(.ozSecondary)
                    .padding(.bottom, 20)
            } else if let countdown = countdown {
                Text("Ozora Festival 2025")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("July 28 - August 3, 2025")
                    .font(.title3)
                    .foregroundColor(.ozSecondary)
                    .padding(.bottom, 20)
                
                Text("Starting in:")
                    .font(.headline)
                    .foregroundColor(.ozSecondary)
                    .padding(.bottom, 5)
                
                HStack(spacing: 20) {
                    CountdownItem(value: countdown.days, unit: "DAYS")
                    CountdownItem(value: countdown.hours, unit: "HOURS")
                    CountdownItem(value: countdown.minutes, unit: "MINS")
                }
            } else {
                Text("Ozora Festival is happening now!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Check out what's playing now")
                    .font(.headline)
                    .foregroundColor(.ozHighlight)
            }
        }
        .padding()
        .onReceive(timeManager.$currentDate) { _ in
            // This will refresh the countdown every minute
        }
    }
}

struct CountdownItem: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .default))
                .foregroundColor(.ozHighlight)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.ozSecondary)
        }
        .frame(minWidth: 70)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}
