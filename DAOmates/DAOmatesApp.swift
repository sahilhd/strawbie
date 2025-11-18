//
//  DAOmatesApp.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI
// MARK: - 🚧 PRODUCTION CODE COMMENTED FOR DEV
// Uncomment when ready to use Firebase
// import FirebaseCore

@main
struct DAOmatesApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // MARK: - 🚧 PRODUCTION: Firebase Configuration
        // Uncomment when ready to use Firebase in production
        // FirebaseApp.configure()
        // print("🔥 Firebase initialized successfully")
        
        print("🛠️ DEV MODE: Running without Firebase for UI development")
        
        // Initialize Spotify service for music search
        _ = SpotifyService.shared
        print("🎧 Spotify service initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
