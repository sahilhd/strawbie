//
//  ProfileView.swift
//  DAOmates
//
//  User Profile Management
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var walletAddress: String = ""
    @State private var showLogoutConfirmation = false
    @State private var showBiometricToggle = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Text(authViewModel.currentUser?.username.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(authViewModel.currentUser?.username ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Edit Profile Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Profile Information")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ProfileTextField(
                                    title: "Username",
                                    placeholder: "Enter username",
                                    text: $username,
                                    icon: "person.fill"
                                )
                                
                                ProfileTextField(
                                    title: "Wallet Address",
                                    placeholder: "Optional",
                                    text: $walletAddress,
                                    icon: "bitcoinsign.circle.fill"
                                )
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                authViewModel.updateProfile(
                                    username: username.isEmpty ? nil : username,
                                    walletAddress: walletAddress
                                )
                            }) {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [.cyan, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                        }
                        
                        // Security Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Security")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                // Biometric Auth Toggle
                                if BiometricAuthService.shared.getBiometricType() != .none {
                                    HStack {
                                        Image(systemName: BiometricAuthService.shared.getBiometricType() == .faceID ? "faceid" : "touchid")
                                            .font(.title3)
                                            .foregroundColor(.cyan)
                                        
                                        Text("Enable \(BiometricAuthService.shared.getBiometricType() == .faceID ? "Face ID" : "Touch ID")")
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Toggle("", isOn: $authViewModel.biometricAuthEnabled)
                                            .tint(.cyan)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                }
                                
                                // Change Password
                                Button(action: {
                                    // Show change password view
                                }) {
                                    HStack {
                                        Image(systemName: "lock.rotation")
                                            .font(.title3)
                                            .foregroundColor(.cyan)
                                        
                                        Text("Change Password")
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Account Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Activity")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                StatsCard(
                                    value: "\(authViewModel.currentUser?.chatHistory.count ?? 0)",
                                    label: "Chats",
                                    icon: "message.fill",
                                    color: .cyan
                                )
                                
                                StatsCard(
                                    value: "\(authViewModel.currentUser?.favoriteAvatars.count ?? 0)",
                                    label: "Favorites",
                                    icon: "heart.fill",
                                    color: .pink
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Logout Button
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Account Info
                        VStack(spacing: 8) {
                            Text("Member since \(formattedDate)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("DAOmates v1.0.0")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            username = authViewModel.currentUser?.username ?? ""
            walletAddress = authViewModel.currentUser?.walletAddress ?? ""
        }
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authViewModel.signOut()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var formattedDate: String {
        guard let createdAt = authViewModel.currentUser?.createdAt else {
            return "Unknown"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
}

struct ProfileTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct StatsCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

