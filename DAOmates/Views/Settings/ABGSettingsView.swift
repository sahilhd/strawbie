//
//  ABGSettingsView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI
import PhotosUI

struct ABGSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var username: String = "Ana"
    @State private var notificationsEnabled = false
    @State private var showDeleteConfirmation = false
    @State private var showPhotosPicker = false
    
    // Mock data
    let signupDate = "November 10, 2025"
    let strawbiesCount = 42
    let modesUnlocked = 4
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark purple to black gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.08, blue: 0.2),
                        Color(red: 0.05, green: 0.02, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for alignment
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Section
                            VStack(spacing: 16) {
                                // Profile Photo with Edit Button
                                ZStack(alignment: .bottomTrailing) {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.pink, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Text(String(username.prefix(1)))
                                                    .font(.system(size: 40, weight: .semibold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    
                                    // Edit photo button
                                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.pink)
                                            .background(
                                                Circle()
                                                    .fill(Color(red: 0.15, green: 0.08, blue: 0.2))
                                                    .frame(width: 32, height: 32)
                                            )
                                    }
                                    .onChange(of: selectedPhotoItem) { oldValue, newValue in
                                        Task {
                                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                                               let image = UIImage(data: data) {
                                                profileImage = image
                                            }
                                        }
                                    }
                                }
                                
                                // Name Field
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Name")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    TextField("Your name", text: $username)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .tint(.pink)
                                }
                                
                                // Friends Since
                                HStack {
                                    Text("Friends since")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Spacer()
                                    
                                    Text(signupDate)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 20)
                            
                            // Activity Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your activity")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                
                                // Strawbies Count
                                HStack {
                                    HStack(spacing: 8) {
                                        Text("🍓")
                                            .font(.system(size: 18))
                                        
                                        Text("Strawbies")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(strawbiesCount)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.pink)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                                
                                // Modes Unlocked
                                HStack {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.orange)
                                        
                                        Text("Modes unlocked")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(modesUnlocked)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // Settings Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Settings")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                
                                // Notifications Toggle
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notifications")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Text("Get updates from Strawbie")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $notificationsEnabled)
                                        .tint(.pink)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // Links Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Legal")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                
                                // TOS Link
                                LinkButton(label: "Terms of Service", action: {
                                    print("Opening Terms of Service")
                                })
                                .padding(.horizontal, 20)
                                
                                // Privacy Policy Link
                                LinkButton(label: "Privacy Policy", action: {
                                    print("Opening Privacy Policy")
                                })
                                .padding(.horizontal, 20)
                            }
                            
                            // Danger Zone
                            VStack(spacing: 12) {
                                Button(action: { showDeleteConfirmation = true }) {
                                    HStack {
                                        Text("Delete Account")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.red)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 20)
                                }
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await authViewModel.deleteAccount()
                        dismiss()
                    }
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
}

// MARK: - Link Button Component
struct LinkButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ABGSettingsView()
}
