//
//  SpotifyService.swift
//  DAOmates
//
//  Spotify Web API integration for music search and playback
//

import Foundation

/// Service for integrating Spotify Web API
class SpotifyService: ObservableObject {
    static let shared = SpotifyService()
    
    @Published var isAuthorized = false
    @Published var accessToken: String?
    
    private let clientId: String
    private let clientSecret: String
    private var tokenExpirationDate: Date?
    
    private init() {
        // Get credentials from Info.plist or environment
        let clientId = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? ""
        
        // Debug: Check what we're actually getting
        print("🔍 DEBUG: Raw plist lookup")
        print("   SPOTIFY_CLIENT_ID from plist: '\(clientId)'")
        print("   SPOTIFY_CLIENT_SECRET from plist: '\(clientSecret)'")
        
        // Fallback: Use hardcoded values for testing (TEMPORARY)
        // These are the same values from your Info.plist
        let finalClientId = clientId.isEmpty ? "7a2863e121cd452cb4473a3a36dabdec" : clientId
        let finalClientSecret = clientSecret.isEmpty ? "2f8f115ecf5647f79a49907e63744d2b" : clientSecret
        
        self.clientId = finalClientId
        self.clientSecret = finalClientSecret
        
        // Debug logging
        print("🎧 Spotify Service Initialized")
        print("   Client ID length: \(finalClientId.count)")
        print("   Client Secret length: \(finalClientSecret.count)")
        
        if finalClientId.isEmpty || finalClientSecret.isEmpty {
            print("⚠️ Spotify credentials empty even with fallback!")
        } else {
            print("✅ Spotify credentials loaded")
            print("   Client ID: \(finalClientId.prefix(10))...")
            if !clientId.isEmpty {
                print("   ℹ️ Loaded from Info.plist")
            } else {
                print("   ℹ️ Using fallback hardcoded values")
            }
        }
    }
    
    // MARK: - Authentication
    
    /// Get access token using Client Credentials Flow (no user login required)
    func getAccessToken() async throws -> String {
        // Check if we have a valid token
        if let token = accessToken,
           let expirationDate = tokenExpirationDate,
           Date() < expirationDate {
            print("✅ Using cached Spotify token")
            return token
        }
        
        print("🔑 Requesting new Spotify access token...")
        
        // Prepare credentials
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw SpotifyError.authenticationFailed
        }
        let base64Credentials = credentialsData.base64EncodedString()
        
        // Create request
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw SpotifyError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Spotify auth failed with status: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("   Error: \(errorString)")
            }
            throw SpotifyError.authenticationFailed
        }
        
        // Parse response
        let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        
        await MainActor.run {
            self.accessToken = tokenResponse.accessToken
            self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn - 60)) // Refresh 1 min early
            self.isAuthorized = true
        }
        
        print("✅ Spotify access token obtained, expires in \(tokenResponse.expiresIn) seconds")
        return tokenResponse.accessToken
    }
    
    // MARK: - Music Search
    
    /// Search for tracks on Spotify
    func searchTracks(query: String, limit: Int = 10) async throws -> [MusicTrack] {
        print("🔍 Searching Spotify for: \(query)")
        
        // Get access token
        let token = try await getAccessToken()
        
        // Create search URL
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components?.url else {
            throw SpotifyError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Spotify search failed with status: \(httpResponse.statusCode)")
            throw SpotifyError.searchFailed
        }
        
        // Parse response
        let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
        
        print("✅ Found \(searchResponse.tracks.items.count) tracks on Spotify")
        
        // Convert to MusicTrack objects - filter out tracks without preview URLs
        let tracks = searchResponse.tracks.items.compactMap { item -> MusicTrack? in
            // Only include tracks that have preview URLs
            guard let previewUrl = item.previewUrl, !previewUrl.isEmpty else {
                print("⏭️ Skipping track (no preview): \(item.name)")
                return nil
            }
            
            return MusicTrack(
                id: item.id,
                title: item.name,
                artist: item.artists.first?.name ?? "Unknown Artist",
                artworkURL: item.album.images.first?.url,
                audioURL: previewUrl, // Spotify preview URL (30 seconds)
                duration: Double(item.durationMs) / 1000.0
            )
        }
        
        print("✅ Filtered \(searchResponse.tracks.items.count) total tracks → \(tracks.count) with preview URLs")
        
        return tracks
    }
}

// MARK: - Models

struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

struct SpotifySearchResponse: Codable {
    let tracks: SpotifyTracksResponse
}

struct SpotifyTracksResponse: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let previewUrl: String?
    let durationMs: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, album
        case previewUrl = "preview_url"
        case durationMs = "duration_ms"
    }
}

struct SpotifyArtist: Codable {
    let name: String
}

struct SpotifyAlbum: Codable {
    let images: [SpotifyImage]
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

// MARK: - Errors

enum SpotifyError: LocalizedError {
    case authenticationFailed
    case invalidURL
    case invalidResponse
    case searchFailed
    case noCredentials
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Failed to authenticate with Spotify. Check your credentials."
        case .invalidURL:
            return "Invalid Spotify API URL."
        case .invalidResponse:
            return "Invalid response from Spotify API."
        case .searchFailed:
            return "Failed to search Spotify catalog."
        case .noCredentials:
            return "Spotify credentials not configured. Add SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET to Info.plist."
        }
    }
}

