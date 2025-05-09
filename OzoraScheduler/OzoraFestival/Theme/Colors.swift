import SwiftUI

extension Color {
    static let ozBackground = Color(hex: "#0A0A0A")
    static let ozHighlight = Color(hex: "#00FF99")
    static let ozSecondary = Color(hex: "#666666")
    static let ozStage1 = Color(hex: "#FF5555") // Dome
    static let ozStage2 = Color(hex: "#55AAFF") // Dragons Nest
    static let ozStage3 = Color(hex: "#FFAA55") // Ozora
    static let ozStage4 = Color(hex: "#AA55FF") // Pumpui
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Stage color helpers
extension Stage {
    var color: Color {
        switch self.name {
        case "Dome Stage":
            return .ozStage1
        case "Dragons Nest":
            return .ozStage2
        case "Ozora":
            return .ozStage3
        case "Pumpui":
            return .ozStage4
        default:
            return .ozHighlight
        }
    }
}
