//
//  AuthViewModel.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showOnboarding = false
    @Published var biometricAuthEnabled: Bool {
        didSet {
            UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuthEnabled")
        }
    }
    
    private let authService = FirebaseAuthService.shared
    private let biometricService = BiometricAuthService.shared
    
    init() {
        // Load biometric preference
        self.biometricAuthEnabled = UserDefaults.standard.bool(forKey: "biometricAuthEnabled")
        
        // 🔧 DEBUG: Force onboarding on every launch for testing
        // Once production ready, uncomment the hasLaunchedBefore check below
        self.showOnboarding = true
        
        // Production code (commented out for now):
        /*
        // Check if this is first launch
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            self.showOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        */
        
        Task {
            await checkAuthStatus()
        }
    }
    
    func checkAuthStatus() async {
        // Check if user is already logged in with Firebase
        if let user = await authService.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
            print("✅ User auto-logged in: \(user.email)")
            
            // Try biometric authentication if enabled
            if biometricAuthEnabled {
                do {
                    let authenticated = try await biometricService.authenticateUser()
                    if !authenticated {
                        await signOut()
                    }
                } catch {
                    // If biometric fails, user can still use password
                    print("⚠️ Biometric authentication failed: \(error.localizedDescription)")
                }
            }
        } else {
            // No user logged in - this is correct behavior
            self.isAuthenticated = false
            self.currentUser = nil
            print("ℹ️ No user logged in - showing auth screen")
        }
    }
    
    func signUp(username: String, email: String, password: String, confirmPassword: String, walletAddress: String? = nil) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            isLoading = false
            return
        }
        
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                username: username,
                walletAddress: walletAddress
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.successMessage = "Account created successfully!"
            
            // Prompt for biometric setup
            if biometricService.getBiometricType() != .none {
                promptBiometricSetup()
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            self.successMessage = "Welcome back!"
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signInWithBiometric() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let authenticated = try await biometricService.authenticateUser()
            if authenticated {
                if let user = await authService.getCurrentUser() {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.successMessage = "Welcome back!"
                }
            }
        } catch let error as BiometricAuthService.BiometricError {
            switch error {
            case .userCancel:
                errorMessage = nil // User chose to cancel
            case .userFallback:
                errorMessage = nil // User chose to use password instead
            case .biometricNotAvailable:
                errorMessage = "Biometric authentication is not available on this device"
            case .biometricNotEnrolled:
                errorMessage = "Please set up Face ID or Touch ID in Settings"
            default:
                errorMessage = "Authentication failed. Please try again"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
            successMessage = "Signed out successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await authService.resetPassword(email: email)
            successMessage = "Password reset email sent. Please check your inbox."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile(username: String?, walletAddress: String?) {
        guard var user = currentUser else { return }
        
        let oldUsername = user.username
        let oldWallet = user.walletAddress
        
        if let username = username, !username.isEmpty {
            user.username = username
        }
        
        if let walletAddress = walletAddress {
            user.walletAddress = walletAddress.isEmpty ? nil : walletAddress
        }
        
        currentUser = user
        
        // Save updated user data to Firestore
        Task {
            do {
                try await authService.updateProfile(
                    userId: user.id,
                    username: oldUsername != user.username ? user.username : nil,
                    walletAddress: oldWallet != user.walletAddress ? user.walletAddress : nil
                )
                await MainActor.run {
                    successMessage = "Profile updated successfully"
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func promptBiometricSetup() {
        // This will be handled by the UI layer
        // Show a prompt asking user if they want to enable biometric auth
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
            currentUser = nil
            isAuthenticated = false
            successMessage = "Account deleted successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
