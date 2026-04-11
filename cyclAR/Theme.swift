//
//  Theme.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//
import SwiftUI
 
// MARK: - Brand Colors
extension Color {
    static let brand        = Color(hex: "#E24B4A")
    static let brandDark    = Color(hex: "#A32D2D")
    static let brandLight   = Color(hex: "#FCEBEB")
    static let brandMid     = Color(hex: "#F7C1C1")
    static let appBlack     = Color(hex: "#1A1A1A")
    static let surfaceGray  = Color(hex: "#F5F5F3")
    static let borderGray   = Color(hex: "#E8E7E4")
    static let textMuted    = Color(hex: "#7A7976")
    static let textSecondary = Color(hex: "#5F5E5A")
}
 
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
 
// MARK: - Typography
extension Font {
    // Display
    static let cyclARLargeTitle = Font.custom("Lexend-Bold", size: 28)
    static let cyclARTitle      = Font.custom("Lexend-SemiBold", size: 20)
    static let cyclARHeadline   = Font.custom("Lexend-SemiBold", size: 15)
    static let cyclARSubhead    = Font.custom("Lexend-Medium", size: 13)
    static let cyclARBody       = Font.custom("Lexend", size: 13)
    static let cyclARCaption    = Font.custom("Lexend", size: 11)
    static let cyclARLabel      = Font.custom("Lexend-SemiBold", size: 10)  // section headers
    static let cyclARLogoFont   = Font.custom("Lexend-Bold", size: 18)
}
 
// MARK: - Reusable View Modifiers
struct CyclARCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
    }
}
 
extension View {
    func cyclARCard() -> some View {
        modifier(CyclARCard())
    }
}
 
struct SectionHeaderLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.cyclARLabel)
            .tracking(0.8)
            .foregroundColor(.textMuted)
    }
}
