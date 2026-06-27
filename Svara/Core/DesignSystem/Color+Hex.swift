import SwiftUI

extension Color {
    /// Creates a color from a hex string such as `#1E1B4B`, `1E1B4B`, or `#FFF`.
    /// Falls back to clear if the string cannot be parsed.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b, a: Double
        switch cleaned.count {
        case 3: // RGB (12-bit)
            r = Double((value >> 8) & 0xF) / 15.0
            g = Double((value >> 4) & 0xF) / 15.0
            b = Double(value & 0xF) / 15.0
            a = 1.0
        case 6: // RRGGBB (24-bit)
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA (32-bit)
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0; a = 0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
