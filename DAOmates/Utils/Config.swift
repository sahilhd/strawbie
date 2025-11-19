//
//  Config.swift
//  DAOmates
//
//  Configuration and Environment Management
//

import Foundation

struct AppConfig {
    // MARK: - API Keys (Should be loaded from environment or secure storage)
    
    static var openAIAPIKey: String {
        // MARK: - 🛠️ DEV MODE: Direct API Key
        // For UI development, use environment variable
        // TODO: Set OPENAI_API_KEY in your environment
        #if DEBUG
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            print("✅ Using OpenAI API key from environment")
            return envKey
        }
        #endif
        
        // First, try to get from environment variable
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty {
            return key
        }
        
        // Try to get from Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !key.isEmpty {
            return key
        }
        
        // For development only - remove in production
        #if DEBUG
        print("⚠️ Warning: No OpenAI API key found. Using mock responses.")
        #endif
        
        return ""
    }
    
    static var youtubeAPIKey: String {
        // Try to get from environment variable first
        if let key = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"], !key.isEmpty {
            print("✅ YouTube API key found in environment variable")
            return key
        }
        
        // Try to get from Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String, !key.isEmpty {
            print("✅ YouTube API key found in Info.plist: \(key.prefix(10))...")
            return key
        }
        
        // Development fallback: Hardcoded key for testing
        // TODO: Remove before production - use Info.plist or environment variable instead
        #if DEBUG
        let devKey = "AIzaSyC_RhsVbMSMfjTttAOYzg14bUeqKWt_7OI"
        print("✅ Using development YouTube API key")
        return devKey
        #endif
        
        return "YOUR_YOUTUBE_API_KEY"
    }
    
    // MARK: - App Information
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Strawbie"
    }
    
    // MARK: - Feature Flags
    
    static let enableBiometricAuth = true
    static let enableWalletIntegration = true
    static let enableAnalytics = false  // Set to true when you add analytics
    
    // MARK: - URLs
    
    static let supportEmail = "support@strawbie.app"
    static let privacyPolicyURL = "https://strawbie.app/privacy"
    static let termsOfServiceURL = "https://strawbie.app/terms"
    static let websiteURL = "https://strawbie.app"
    
    // MARK: - API Configuration
    
    static let apiTimeout: TimeInterval = 30.0
    static let maxRetries = 3
    
    // MARK: - Chat Configuration
    
    static let maxChatHistoryLength = 30          // Increased from 10 for better context
    static let maxTokens = 600                     // Increased from 300 for longer responses
    static let temperature: Double = 0.8
    
    // MARK: - Music Service Configuration
    
    /// Sample track URLs for music playback (not hardcoded, loaded from config)
    /// These are royalty-free music tracks that work with AVPlayer
    static let sampleTrackURLs = [
        // Royalty-free music from various sources
        "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
        "https://commondatastorage.googleapis.com/codeskulptor-assets/Epoq-Lepidoptera.ogg",
        "https://commondatastorage.googleapis.com/codeskulptor-assets/Evillaugh.ogg",
        "https://www.bensound.com/bensound-music/bensound-ukulele.mp3",
        "https://www.bensound.com/bensound-music/bensound-sunny.mp3",
        "https://www.bensound.com/bensound-music/bensound-creativeminds.mp3"
    ]
    
    // MARK: - Storage Keys
    
    enum StorageKey {
        static let currentUser = "currentUser"
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let biometricAuthEnabled = "biometricAuthEnabled"
        static let userBirthYear = "userBirthYear"
    }
    
    // MARK: - Keychain Keys
    
    enum KeychainKey {
        static let userEmail = "userEmail"
        static let userPassword = "userPassword"
        static let userData = "userData"
        static let apiKey = "apiKey"
    }
}

// MARK: - Environment Detection

enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.daomates.app"
        case .staging:
            return "https://staging-api.daomates.app"
        case .production:
            return "https://api.daomates.app"
        }
    }
}

