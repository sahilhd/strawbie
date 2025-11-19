//
//  OutfitSelectionView.swift
//  DAOmates
//
//  Created by Assistant on 2025-09-03.
//

import SwiftUI
import AVFoundation

struct OutfitSelectionView: View {
    @Binding var selectedOutfit: Outfit
    @Binding var isPresented: Bool
    @Binding var selectedMode: String
    @State private var outfits: [Outfit] = []
    @State private var modes: [ChatMode] = []
    @State private var selectedModeId: String = "pocket"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.15),
                        Color(red: 0.2, green: 0.1, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button("Exit") {
                                isPresented = false
                            }
                            .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("Modes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Go") {
                                print("🔘 DEBUG: Go button tapped")
                                print("🔘 DEBUG: selectedModeId = \(selectedModeId)")
                                selectedMode = selectedModeId
                                print("🔘 DEBUG: selectedMode set to = \(selectedMode)")
                                
                                // Update the outfit to match the selected mode
                                if let selectedModeData = modes.first(where: { $0.id == selectedModeId }) {
                                    // Map mode ID to outfit category
                                    let category: Outfit.OutfitCategory = {
                                        switch selectedModeId {
                                        case "pocket": return .pocket
                                        case "chill": return .chill
                                        case "study": return .study
                                        case "sleep": return .sleep
                                        default: return .pocket
                                        }
                                    }()
                                    
                                    selectedOutfit = Outfit(
                                        id: UUID(),
                                        name: selectedModeData.name,
                                        description: selectedModeData.description,
                                        videoFileName: selectedModeData.videoFileName,
                                        thumbnailName: selectedModeData.thumbnailName,
                                        category: category,
                                        isUnlocked: selectedModeData.isUnlocked
                                    )
                                }
                                
                                isPresented = false
                            }
                            .foregroundColor(.pink)
                            .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 20)
                    
                    // Modes Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(modes) { mode in
                                ModeCard(
                                    mode: mode,
                                    isSelected: selectedModeId == mode.id
                                ) {
                                    if mode.isUnlocked {
                                        print("🎯 DEBUG: Mode card tapped: \(mode.name) (id: \(mode.id))")
                                        selectedModeId = mode.id
                                        print("✅ DEBUG: selectedModeId updated to: \(selectedModeId)")
                                    } else {
                                        print("🔒 DEBUG: Mode \(mode.name) is locked")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            loadModes()
            // Initialize with the currently selected mode from parent
            selectedModeId = selectedMode
        }
    }
    
    private func loadModes() {
        modes = [
            ChatMode(
                id: "pocket",
                emoji: "👜",
                name: "Pocket Mode",
                description: "Your everyday bestie vibes",
                videoFileName: "pocketmode.mp4",
                thumbnailName: "pocketmode",
                isUnlocked: true,
                unlockedAt: nil
            ),
            ChatMode(
                id: "chill",
                emoji: "😎",
                name: "Chill Mode",
                description: "Relaxed and laid-back energy",
                videoFileName: "chillmode.mp4",
                thumbnailName: "chillmode",
                isUnlocked: true,
                unlockedAt: nil
            ),
            ChatMode(
                id: "study",
                emoji: "📚",
                name: "Study Mode",
                description: "Focused and motivated",
                videoFileName: "studymode.mp4",
                thumbnailName: "studymode",
                isUnlocked: true,
                unlockedAt: nil
            ),
            ChatMode(
                id: "sleep",
                emoji: "😴",
                name: "Sleep Mode",
                description: "Calm and soothing",
                videoFileName: "sleepmode.mp4",
                thumbnailName: "sleepmode",
                isUnlocked: true,
                unlockedAt: nil
            ),
            ChatMode(
                id: "cafe",
                emoji: "☕",
                name: "Café Mode",
                description: "Cozy coffee shop vibes",
                videoFileName: "studymode.mp4",
                thumbnailName: "studymode",
                isUnlocked: false,
                unlockedAt: 50
            ),
            ChatMode(
                id: "premium",
                emoji: "✨",
                name: "Premium Mode",
                description: "Exclusive VIP experience",
                videoFileName: "sleepmode.mp4",
                thumbnailName: "sleepmode",
                isUnlocked: false,
                unlockedAt: 100
            )
        ]
    }
}

// MARK: - Chat Mode Model
struct ChatMode: Identifiable {
    let id: String
    let emoji: String
    let name: String
    let description: String
    let videoFileName: String
    let thumbnailName: String
    let isUnlocked: Bool
    let unlockedAt: Int?
}

// MARK: - Mode Card
struct ModeCard: View {
    let mode: ChatMode
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Video preview thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.pink.opacity(0.25), .purple.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 160)

                    ModeThumbnail(mode: mode)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Selection indicator
                    if isSelected && mode.isUnlocked {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.pink, lineWidth: 3)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.pink)
                                    .background(Color.black)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                    
                    // Lock indicator for locked modes
                    if !mode.isUnlocked {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.7))
                            
                            VStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                if let unlockedAt = mode.unlockedAt {
                                    Text("🍓 \(unlockedAt)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                
                // Mode info
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text(mode.emoji)
                            .font(.title3)
                        Text(mode.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(mode.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!mode.isUnlocked)
        .contentShape(Rectangle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0)
                .onChanged { _ in
                    if mode.isUnlocked {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Mode Thumbnail
private struct ModeThumbnail: View {
    let mode: ChatMode
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let thumbnailName = mode.isUnlocked ? mode.thumbnailName : nil,
               let uiImage = UIImage(named: thumbnailName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Subtle placeholder while generating
                ZStack {
                    LinearGradient(
                        colors: [.black.opacity(0.2), .black.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    VStack(spacing: 6) {
                        if mode.isUnlocked {
                            ProgressView()
                                .tint(.white)
                            Text("Generating preview…")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Locked")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .task { 
                    if mode.isUnlocked {
                        await generateThumbnail() 
                    }
                }
            }
        }
    }
    
    private func generateThumbnailURL() -> URL? {
        let name = mode.videoFileName
        let fileName = name.replacingOccurrences(of: ".mov", with: "").replacingOccurrences(of: ".mp4", with: "")
        let ext = name.contains(".mp4") ? "mp4" : "mov"
        // 1) In main bundle
        if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
            return url
        }
        // 2) In images/outfits folder inside bundle
        if let outfitsPath = Bundle.main.path(forResource: "outfits", ofType: nil) {
            let path = outfitsPath + "/" + name
            if FileManager.default.fileExists(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        return nil
    }
    
    private func generateThumbnail() async {
        guard let url = generateThumbnailURL() else { return }
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.2, preferredTimescale: 600)
        
        return await withCheckedContinuation { continuation in
            generator.generateCGImageAsynchronously(for: time, completionHandler: { cgImage, actualTime, error in
                if let cgImage = cgImage {
                    let uiImage = UIImage(cgImage: cgImage)
                    Task { @MainActor in
                        self.image = uiImage
                    }
                }
                continuation.resume()
            })
        }
    }
}

#Preview {
    OutfitSelectionView(
        selectedOutfit: .constant(Outfit.sampleOutfits[0]),
        isPresented: .constant(true),
        selectedMode: .constant("pocket")
    )
}
