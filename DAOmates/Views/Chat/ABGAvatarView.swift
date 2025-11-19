//
//  ABGAvatarView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct ABGAvatarView: View {
    let avatar: Avatar
    let isAnimating: Bool
    let onTap: () -> Void
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background glow effect with kawaii colors
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pink.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 250, height: 250)
                .scaleEffect(pulseScale)
                .animation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            // Main avatar container
            Button(action: onTap) {
                ZStack {
                    // Avatar image frame
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [.pink, .purple, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                    
                    // ABG Image (placeholder for now - will show when image is properly added)
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .pink],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text("ABG")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Kawaii sparkles
                    ForEach(0..<8, id: \.self) { index in
                        let angle = Double(index) * 45
                        let sparkles = ["✨", "💖", "🌸", "⭐"]
                        
                        Text(sparkles[index % sparkles.count])
                            .font(.title3)
                            .foregroundColor(.pink.opacity(0.8))
                            .offset(
                                x: cos(Angle.degrees(angle + rotationAngle).radians) * (100 + sparkleOffset),
                                y: sin(Angle.degrees(angle + rotationAngle).radians) * (100 + sparkleOffset)
                            )
                            .scaleEffect(pulseScale * 0.8)
                    }
                    
                    // Speaking indicator for ABG
                    if isAnimating {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.pink.opacity(0.6), lineWidth: 2)
                                .frame(width: 200 + CGFloat(index * 20), height: 220 + CGFloat(index * 20))
                                .scaleEffect(pulseScale)
                                .animation(
                                    Animation.easeInOut(duration: 1.2)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.3),
                                    value: pulseScale
                                )
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            pulseScale = 1.1
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                sparkleOffset = 20
            }
        }
    }
}

#Preview {
    ABGAvatarView(
        avatar: Avatar.sampleAvatars[0],
        isAnimating: true,
        onTap: {}
    )
    .background(Color.black)
}
