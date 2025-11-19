//
//  CryptoTheme.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct CryptoTheme {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.cyan
        static let secondary = Color.purple
        static let accent = Color.pink
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        
        static let background = LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color(red: 0.05, green: 0.1, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardBackground = Color.white.opacity(0.1)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.8)
        static let textTertiary = Color.white.opacity(0.6)
    }
    
    // MARK: - Gradients
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primary, Colors.secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accent = LinearGradient(
            colors: [Colors.accent, Colors.secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let success = LinearGradient(
            colors: [Colors.success, Colors.primary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static func forCryptoFocus(_ focus: Avatar.CryptoFocus) -> LinearGradient {
            switch focus {
            case .defi:
                return LinearGradient(colors: [.green, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .nft:
                return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .trading:
                return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .dao:
                return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .blockchain:
                return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .metaverse:
                return LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let pill: CGFloat = 25
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animations
    struct Animations {
        static let quick = Animation.easeInOut(duration: 0.2)
        static let smooth = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.5)
        static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bounce = Animation.interpolatingSpring(stiffness: 300, damping: 15)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func cryptoCard() -> some View {
        self
            .background(CryptoTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CryptoTheme.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: CryptoTheme.CornerRadius.large)
                    .stroke(CryptoTheme.Colors.primary.opacity(0.3), lineWidth: 1)
            )
    }
    
    func cryptoButton(style: CryptoButtonStyle = .primary) -> some View {
        self
            .font(CryptoTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: CryptoTheme.CornerRadius.medium))
    }
    
    func glowEffect(color: Color = CryptoTheme.Colors.primary, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 0)
    }
}

enum CryptoButtonStyle {
    case primary
    case secondary
    case accent
    case success
    case warning
    case error
    
    var background: some View {
        switch self {
        case .primary:
            return AnyView(CryptoTheme.Gradients.primary)
        case .secondary:
            return AnyView(Color.gray.opacity(0.3))
        case .accent:
            return AnyView(CryptoTheme.Gradients.accent)
        case .success:
            return AnyView(CryptoTheme.Gradients.success)
        case .warning:
            return AnyView(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
        case .error:
            return AnyView(LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
