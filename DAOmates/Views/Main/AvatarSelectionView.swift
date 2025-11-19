//
//  AvatarSelectionView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct AvatarSelectionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedAvatar: Avatar?
    @State private var showChatView = false
    @State private var searchText = ""
    @State private var showSettings = false
    @AppStorage("userBirthYear") private var userBirthYear: Int?
    @State private var showAgeGate = false
    @State private var topMode: TopMode = .ask
    
    private var filteredAvatars: [Avatar] {
        if searchText.isEmpty {
            return Avatar.sampleAvatars
        } else {
            return Avatar.sampleAvatars.filter { avatar in
                avatar.name.localizedCaseInsensitiveContains(searchText) ||
                avatar.specialization.localizedCaseInsensitiveContains(searchText) ||
                avatar.cryptoFocus.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Clean dark background like Grok
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top banner (Ask / Imagine) and quick controls
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.08)))
                        }
                        Spacer()
                        
                        // Profile Button
                        Button(action: { showSettings = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 36, height: 36)
                                
                                if let user = authViewModel.currentUser {
                                    Text(user.username.prefix(1).uppercased())
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Segmented Ask / Imagine with NEW badge
                    HStack(spacing: 8) {
                        SegmentPill(title: "Ask", isActive: topMode == .ask) {
                            topMode = .ask
                        }
                        SegmentPill(title: "Imagine", isActive: topMode == .imagine) {
                            topMode = .imagine
                        }
                        Text("NEW")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.06)))
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                
                // Pure avatar selection - horizontal scroll
                VStack(spacing: 16) {
                    // Carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(filteredAvatars) { avatar in
                                SelectableAvatarCard(avatar: avatar, isSelected: selectedAvatar?.id == avatar.id) {
                                    selectedAvatar = avatar
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }

                    // Birth year selector and Continue
                    HStack(spacing: 12) {
                        Menu {
                            Picker("Birth Year", selection: Binding(
                                get: { userBirthYear ?? Calendar.current.component(.year, from: Date()) - 24 },
                                set: { userBirthYear = $0 }
                            )) {
                                ForEach(Array((Calendar.current.component(.year, from: Date()) - 80)...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) { y in
                                    Text("\(y)").tag(y)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar").font(.subheadline)
                                Text(userBirthYear != nil ? "\(userBirthYear!)" : "Select birth year")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
                        }

                        Button(action: { if let _ = userBirthYear, selectedAvatar != nil { showChatView = true } else { showAgeGate = true } }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 14).fill((userBirthYear != nil && selectedAvatar != nil) ? Color.white : Color.white.opacity(0.3)))
                        }
                        .disabled(userBirthYear == nil || selectedAvatar == nil)
                    }
                    .padding(.horizontal, 20)
                }
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                Spacer(minLength: 0)
            }
        }
        .sheet(isPresented: $showChatView) {
            if let avatar = selectedAvatar {
                if avatar.name == "ABG" {
                    ABGChatView(avatar: avatar)
                } else {
                    ChatView(avatar: avatar)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            ProfileView()
        }
        .sheet(isPresented: $showAgeGate) {
            AgeGateView { year in
                userBirthYear = year
                showAgeGate = false
            }
            .presentationDetents([.fraction(0.45)])
        }
        .onAppear {
            if userBirthYear == nil { showAgeGate = true }
        }
    }
}

// MARK: - Top Mode
private enum TopMode { case ask, imagine }

// MARK: - Segment Pill
private struct SegmentPill: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(isActive ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isActive ? Color.white : Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Age Gate
private struct AgeGateView: View {
    let onContinue: (Int) -> Void
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date()) - 24
    private let years: [Int] = Array((Calendar.current.component(.year, from: Date()) - 80)...Calendar.current.component(.year, from: Date())).reversed()
    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.white.opacity(0.2)).frame(width: 40, height: 4).padding(.top, 8)
            Text("Confirm your age to continue")
                .font(.headline).foregroundColor(.white)
            Text("Select when you were born")
                .font(.subheadline).foregroundColor(.white.opacity(0.7))
            Picker("Birth Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            
            Button(action: { onContinue(selectedYear) }) {
                Text("Continue").font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color.black)
    }
}

// MARK: - Voice Settings Sheet
private struct VoiceSettingsView: View {
    let dismiss: () -> Void
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Companion")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Avatar.sampleAvatars) { avatar in
                                VStack(spacing: 6) {
                                    Circle().fill(Color.white.opacity(0.08)).frame(width: 54, height: 54)
                                    Text(avatar.name).font(.caption2).foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                Section {
                    HStack {
                        Image(systemName: "trash"); Text("Erase Conversation")
                    }
                    HStack {
                        Image(systemName: "headphones"); Text("Select Audio Device")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .foregroundColor(.white)
            .navigationTitle("Voice Settings")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done", action: dismiss) } }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Selectable Avatar Card
private struct SelectableAvatarCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                // Circular avatar chip
                ZStack(alignment: .topTrailing) {
                    Group {
                        if avatar.name == "ABG", let uiImage = UIImage(named: "abg_avatar") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            LinearGradient(
                                colors: gradientColors(for: avatar.cryptoFocus),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.pink : Color.white.opacity(0.15), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)

                    // Small badge (decorative)
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 18, height: 18)
                        .overlay(Image(systemName: "heart.fill").font(.system(size: 9, weight: .bold)).foregroundColor(.pink))
                        .offset(x: 6, y: -6)
                }

                // Name + age tag
                VStack(spacing: 2) {
                    Text(avatar.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("18+")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(width: 86)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private func gradientColors(for focus: Avatar.CryptoFocus) -> [Color] {
        switch focus {
        case .defi:
            return [.green, .cyan]
        case .nft:
            return [.purple, .pink]
        case .trading:
            return [.orange, .red]
        case .dao:
            return [.blue, .purple]
        case .blockchain:
            return [.yellow, .orange]
        case .metaverse:
            return [.pink, .purple]
        }
    }
    
    private func avatarIcon(for focus: Avatar.CryptoFocus) -> String {
        switch focus {
        case .defi:
            return "chart.line.uptrend.xyaxis"
        case .nft:
            return "photo.artframe"
        case .trading:
            return "chart.bar.fill"
        case .dao:
            return "person.3.sequence.fill"
        case .blockchain:
            return "link"
        case .metaverse:
            return "visionpro"
        }
    }
    
    private func ageText(for avatar: Avatar) -> String {
        switch avatar.name {
        case "ABG":
            return "18+"
        case "Satoshi":
            return "18+"
        case "Valentine":
            return "18+"
        default:
            return "18+"
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    AvatarSelectionView()
        .environmentObject(AuthViewModel())
}
