//
//  MusicPlayerWidget.swift
//  DAOmates
//
//  Created by AI Assistant on 2025-11-13.
//

import SwiftUI

struct MusicPlayerWidget: View {
    @ObservedObject var musicService: MusicService
    
    var body: some View {
        VStack(spacing: 12) {
            // Album Art + Track Info in Row
            HStack(spacing: 12) {
                // Album Art
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.8, green: 0.9, blue: 0.2), Color(red: 0.7, green: 0.8, blue: 0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(String(musicService.currentTrack?.title.prefix(1) ?? "♪"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(width: 56, height: 56)
                
                // Track Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(musicService.currentTrack?.title ?? "No track")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(musicService.currentTrack?.artist ?? "Unknown")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 8) {
                    // Previous
                    Button(action: { musicService.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Play/Pause
                    Button(action: { musicService.togglePlayPause() }) {
                        Image(systemName: musicService.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Next
                    Button(action: { musicService.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            MusicPlayerWidget(musicService: MusicService.shared)
                .padding(.bottom, 100)
        }
    }
}
