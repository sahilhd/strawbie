//
//  AppleMusicService.swift
//  DAOmates
//
//  Created by AI Assistant on 2025-11-17.
//

import Foundation
import MusicKit

/// Service for integrating Apple Music using MusicKit
@available(iOS 15.0, *)
class AppleMusicService: ObservableObject {
    static let shared = AppleMusicService()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        Task {
            let status = MusicAuthorization.currentStatus
            await MainActor.run {
                self.authorizationStatus = status
                self.isAuthorized = (status == .authorized)
            }
            
            print("🎵 Apple Music authorization status: \(status)")
            
            // Check subscription status
            await checkSubscriptionStatus()
        }
    }
    
    /// Check if user has an active Apple Music subscription
    func checkSubscriptionStatus() async {
        // Request subscription updates to get current status
        for await subscription in MusicSubscription.subscriptionUpdates {
            print("🎵 Apple Music subscription status:")
            print("   - Can play catalog content: \(subscription.canPlayCatalogContent)")
            print("   - Can become subscriber: \(subscription.canBecomeSubscriber)")
            
            if !subscription.canPlayCatalogContent {
                print("⚠️ WARNING: User cannot play Apple Music catalog content")
                print("   This usually means no active Apple Music subscription")
            }
            
            // Only check once
            break
        }
    }
    
    /// Request authorization to access Apple Music
    func requestAuthorization() async -> Bool {
        let status = await MusicAuthorization.request()
        
        await MainActor.run {
            self.authorizationStatus = status
            self.isAuthorized = (status == .authorized)
        }
        
        print("🎵 Apple Music authorization result: \(status)")
        return status == .authorized
    }
    
    // MARK: - Music Search
    
    /// Search for songs on Apple Music
    func searchSongs(query: String, limit: Int = 10) async throws -> [MusicTrack] {
        guard isAuthorized else {
            print("❌ Not authorized to access Apple Music")
            throw AppleMusicError.notAuthorized
        }
        
        print("🔍 Searching Apple Music for: \(query)")
        
        // Create search request
        var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
        request.limit = limit
        
        // Perform search
        let response = try await request.response()
        
        // MusicItemCollection is not optional, check if empty instead
        let songs = response.songs
        
        guard !songs.isEmpty else {
            print("⚠️ No songs found for query: \(query)")
            return []
        }
        
        print("✅ Found \(songs.count) songs on Apple Music")
        
        // Convert to MusicTrack objects
        let tracks = songs.compactMap { song -> MusicTrack? in
            guard let url = song.url else { return nil }
            
            return MusicTrack(
                id: song.id.rawValue,
                title: song.title,
                artist: song.artistName,
                artworkURL: song.artwork?.url(width: 300, height: 300)?.absoluteString,
                audioURL: url.absoluteString,
                duration: song.duration ?? 180.0
            )
        }
        
        return tracks
    }
    
    /// Search for songs by genre
    func searchByGenre(genre: String, limit: Int = 10) async throws -> [MusicTrack] {
        // Map common genre terms to Apple Music genre queries
        let genreQuery: String
        
        switch genre.lowercased() {
        case "lofi", "lo-fi", "study":
            genreQuery = "lofi hip hop study beats"
        case "jazz":
            genreQuery = "smooth jazz instrumental"
        case "rock":
            genreQuery = "classic rock"
        case "pop":
            genreQuery = "pop hits"
        case "edm", "electronic":
            genreQuery = "electronic dance music"
        case "ambient", "chill":
            genreQuery = "ambient chill music"
        case "sleep", "relaxing":
            genreQuery = "sleep relaxing music"
        case "metal":
            genreQuery = "metal rock"
        case "hip hop", "rap":
            genreQuery = "hip hop rap"
        default:
            genreQuery = "\(genre) music"
        }
        
        return try await searchSongs(query: genreQuery, limit: limit)
    }
    
    // MARK: - Playback
    
    /// Get the system music player
    var systemMusicPlayer: SystemMusicPlayer {
        return SystemMusicPlayer.shared
    }
    
    /// Play a song using the system music player
    func playSong(id: String) async throws {
        guard isAuthorized else {
            throw AppleMusicError.notAuthorized
        }
        
        print("🎵 Playing song with ID: \(id)")
        
        // Create a music item ID and request the song
        let musicItemID = MusicItemID(id)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        request.limit = 1
        
        let response = try await request.response()
        
        guard let song = response.items.first else {
            print("❌ Could not find song with ID: \(id)")
            throw AppleMusicError.playbackFailed
        }
        
        // Set the queue and start playback
        try await systemMusicPlayer.queue.insert(song, position: .tail)
        try await systemMusicPlayer.play()
        
        print("▶️ Apple Music playback started")
    }
    
    /// Play a list of songs
    func playTracks(_ tracks: [MusicTrack]) async throws {
        guard isAuthorized else {
            print("❌ Not authorized for Apple Music")
            throw AppleMusicError.notAuthorized
        }
        
        // Check subscription status by attempting to get current subscription
        var canPlay = false
        for await subscription in MusicSubscription.subscriptionUpdates {
            canPlay = subscription.canPlayCatalogContent
            if !canPlay {
                print("❌ Cannot play Apple Music catalog content - subscription required")
                print("   Can become subscriber: \(subscription.canBecomeSubscriber)")
                throw AppleMusicError.subscriptionRequired
            }
            print("✅ Subscription verified - can play catalog content")
            break
        }
        
        guard !tracks.isEmpty else {
            print("⚠️ No tracks to play")
            return
        }
        
        print("🎵 Playing \(tracks.count) tracks from Apple Music")
        
        // Convert track IDs to MusicItemIDs
        let musicItemIDs = tracks.map { MusicItemID($0.id) }
        
        // Request all songs at once
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, memberOf: musicItemIDs)
        request.limit = tracks.count
        
        do {
            let response = try await request.response()
            let songs = Array(response.items)
            
            guard !songs.isEmpty else {
                print("❌ Failed to fetch songs from Apple Music")
                throw AppleMusicError.playbackFailed
            }
            
            print("✅ Fetched \(songs.count) songs from Apple Music")
            
            // Clear existing queue first
            systemMusicPlayer.queue = []
            print("🗑️ Cleared existing queue")
            
            // Insert songs into queue
            for (index, song) in songs.enumerated() {
                try await systemMusicPlayer.queue.insert(song, position: .tail)
                print("   [\(index + 1)/\(songs.count)] Added: \(song.title)")
            }
            
            // Start playback
            try await systemMusicPlayer.play()
            
            print("▶️ Apple Music playback started with \(songs.count) songs")
            print("🎵 Now playing: \(songs.first?.title ?? "Unknown")")
            
        } catch {
            print("❌ Error during Apple Music playback: \(error)")
            print("   Error details: \(error.localizedDescription)")
            throw AppleMusicError.playbackFailed
        }
    }
    
    /// Pause playback
    func pause() {
        systemMusicPlayer.pause()
        print("⏸️ Apple Music paused")
    }
    
    /// Resume playback
    func play() async throws {
        try await systemMusicPlayer.play()
        print("▶️ Apple Music resumed")
    }
    
    /// Skip to next track
    func skipToNext() async throws {
        try await systemMusicPlayer.skipToNextEntry()
        print("⏭️ Skipped to next track")
    }
    
    /// Skip to previous track
    func skipToPrevious() async throws {
        try await systemMusicPlayer.skipToPreviousEntry()
        print("⏮️ Skipped to previous track")
    }
    
    /// Stop playback
    func stop() {
        systemMusicPlayer.queue = []
        print("⏹️ Apple Music stopped")
    }
}

// MARK: - Errors

enum AppleMusicError: LocalizedError {
    case notAuthorized
    case searchFailed
    case playbackFailed
    case subscriptionRequired
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Apple Music access not authorized. Please enable in Settings."
        case .searchFailed:
            return "Failed to search Apple Music catalog."
        case .playbackFailed:
            return "Failed to start Apple Music playback."
        case .subscriptionRequired:
            return "Apple Music subscription required to play music. Please subscribe in the Music app."
        }
    }
}

