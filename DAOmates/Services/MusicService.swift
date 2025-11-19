//
//  MusicService.swift
//  DAOmates
//
//  Created by AI Assistant on 2025-11-13.
//

import Foundation
import AVFoundation
import Combine

// MARK: - Track Model
struct MusicTrack: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: String?
    let audioURL: String
    let duration: Double
}

// MARK: - Music Service
class MusicService: NSObject, ObservableObject {
    static let shared = MusicService()
    
    // MARK: - Published Properties
    @Published var currentTrack: MusicTrack?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var progress: Double = 0
    @Published var playlist: [MusicTrack] = []
    @Published var currentIndex: Int = 0
    
    // MARK: - Private Properties
    private var audioPlayer: AVPlayer?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
        private func setupAudioSession() {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                
                // Configure for playback with speaker output
                try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
                try audioSession.setActive(true)
                
                print("✅ Audio session configured for music playback")
                print("🔊 Category: \(audioSession.category)")
                print("🔊 Mode: \(audioSession.mode)")
                print("🔊 Output route: \(audioSession.currentRoute.outputs.map { $0.portName })")
                print("🔊 Volume: \(audioSession.outputVolume)")
                print("🔊 Is other audio playing: \(audioSession.isOtherAudioPlaying)")
                
            } catch {
                print("❌ Failed to setup audio session: \(error.localizedDescription)")
            }
        }
    
    // MARK: - Test Function
    /// Test music playback with a direct URL
    func testPlayback() {
        print("🧪 Testing music playback...")
        
        let testTrack = MusicTrack(
            id: "test-1",
            title: "Test Track",
            artist: "Test Artist",
            artworkURL: nil,
            audioURL: AppConfig.sampleTrackURLs.first ?? "",
            duration: 180.0
        )
        
        play(track: testTrack)
    }
    
    // MARK: - Playback Controls
    func play(track: MusicTrack) {
        currentTrack = track
        
        print("🎵 Attempting to play: \(track.title)")
        print("📱 Audio URL: \(track.audioURL)")
        
        guard let url = URL(string: track.audioURL) else {
            print("❌ Invalid audio URL: \(track.audioURL)")
            return
        }
        
        // Verify URL is valid
        print("✅ URL is valid: \(url)")
        
        // Clean up old player first
        if let observer = timeObserver, let oldPlayer = audioPlayer {
            oldPlayer.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // Create player item directly (YouTube URLs should work without custom headers)
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        print("🎵 Created AVPlayer with YouTube audio URL")
        
        // Check volume
        let volume = AVAudioSession.sharedInstance().outputVolume
        print("🔊 Device volume: \(volume)")
        
        // Setup time observer
        setupTimeObserver()
        
        // Setup end notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Monitor player item status using KVO
        statusObservation = playerItem.observe(\.status) { [weak self] item, _ in
            print("📊 Player item status changed: \(item.status.rawValue)")
            
            if item.status == .readyToPlay {
                print("✅ Player item ready to play!")
                if self?.isPlaying == true {
                    self?.audioPlayer?.play()
                    print("▶️ Playing after status ready")
                }
            } else if item.status == .failed {
                print("❌ Player item failed: \(item.error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        // Set playing state and start play
        isPlaying = true
        duration = track.duration
        
        print("🎵 Now playing: \(track.title) by \(track.artist)")
        print("🔊 Initial player status: \(audioPlayer?.status.rawValue ?? -1)")
        
        // Immediate play attempt
        audioPlayer?.play()
        print("▶️ Play() called immediately")
        
        // Verify after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let player = self.audioPlayer {
                print("📊 Current time: \(player.currentTime().seconds)")
                print("🔊 Player rate: \(player.rate)")
                print("🔊 Final player status: \(player.status.rawValue)")
                
                if player.rate == 0 {
                    print("⚠️ Playback not started, attempting again...")
                    player.play()
                }
            }
        }
    }
    
    func togglePlayPause() {
        guard audioPlayer != nil else {
            // If no track is playing, play the first track in playlist
            if !playlist.isEmpty {
                play(track: playlist[0])
            }
            return
        }
        
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            print("⏸️ Paused")
        } else {
            audioPlayer?.play()
            isPlaying = true
            print("▶️ Resumed")
        }
    }
    
    func nextTrack() {
        guard !playlist.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % playlist.count
        play(track: playlist[currentIndex])
    }
    
    func previousTrack() {
        guard !playlist.isEmpty else { return }
        
        if currentTime > 3.0 {
            // If more than 3 seconds in, restart current track
            audioPlayer?.seek(to: .zero)
        } else {
            // Otherwise go to previous track
            currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
            play(track: playlist[currentIndex])
        }
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        progress = 0
        print("⏹️ Stopped")
    }
    
    // MARK: - Time Observer
    private func setupTimeObserver() {
        // Remove existing observer
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        
        // Add new observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            self.currentTime = time.seconds
            
            if self.duration > 0 {
                self.progress = self.currentTime / self.duration
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        print("🎵 Track finished, playing next...")
        nextTrack()
    }
    
    // MARK: - Music Search & Integration
    
    /// Search for music based on user request
    /// Priority: 1) YouTube, 2) Sample tracks
    func searchAndPlay(query: String) async {
        print("🎵 searchAndPlay called with query: \(query)")
        
        // Try YouTube first
        await searchYouTubeOrSample(query: query)
    }
    
    /// Search YouTube or use sample tracks
    private func searchYouTubeOrSample(query: String) async {
        do {
            // Try YouTube Data API v3
            print("🔍 Searching YouTube Data API v3 for: \(query)")
            let youTubeResults = try await YouTubeService.shared.searchMusic(query: query)
            
            if !youTubeResults.isEmpty {
                print("✅ Found \(youTubeResults.count) tracks from YouTube")
                await MainActor.run {
                    self.playlist = youTubeResults
                    self.currentIndex = 0
                    print("🎵 Playing first track: \(youTubeResults[0].title)")
                    self.play(track: youTubeResults[0])
                }
            } else {
                print("⚠️ No YouTube results, falling back to sample tracks")
                fallbackToSampleTracks(for: query)
            }
        } catch {
            print("❌ YouTube search failed: \(error.localizedDescription)")
            print("⚠️ Falling back to sample tracks")
            fallbackToSampleTracks(for: query)
        }
    }
    
    /// Fallback to sample tracks if YouTube search fails
    private func fallbackToSampleTracks(for query: String) {
        let sampleTracks = createSamplePlaylist(for: query)
        
        Task { @MainActor in
            print("🎵 Loading fallback sample tracks: \(sampleTracks.count) tracks")
            self.playlist = sampleTracks
            if !sampleTracks.isEmpty {
                self.currentIndex = 0
                print("🎵 Playing first track: \(sampleTracks[0].title)")
                self.play(track: sampleTracks[0])
            }
        }
    }
    
    /// Create sample playlist based on user query
    private func createSamplePlaylist(for query: String) -> [MusicTrack] {
        let lowercaseQuery = query.lowercased()
        print("🎵 Creating sample playlist for query: \(query)")
        
        // Get sample URLs from AppConfig (not hardcoded)
        let urls = AppConfig.sampleTrackURLs
        guard !urls.isEmpty else {
            print("❌ No sample URLs configured!")
            return []
        }
        
        // Genre-specific sample tracks (metadata only, URLs from config)
        let genreMap: [String: [(title: String, artist: String, duration: Double)]] = [
            "metal": [
                ("Energetic Rock", "Sample Artist", 180.0),
                ("Heavy Beats", "Sample Artist", 200.0),
                ("Power Chords", "Sample Artist", 190.0),
            ],
            "rock": [
                ("Classic Rock Vibes", "Sample Artist", 180.0),
                ("Guitar Solo", "Sample Artist", 200.0),
                ("Rock Anthem", "Sample Artist", 210.0),
            ],
            "pop": [
                ("Upbeat Pop", "Sample Artist", 180.0),
                ("Catchy Melody", "Sample Artist", 190.0),
                ("Pop Hits", "Sample Artist", 200.0),
            ],
            "hip hop": [
                ("Hip Hop Beats", "Sample Artist", 180.0),
                ("Rap Flow", "Sample Artist", 200.0),
                ("Urban Vibes", "Sample Artist", 190.0),
            ],
            "lofi": [
                ("Chill Lofi Beats", "Lofi Artist", 180.0),
                ("Study Session", "Lofi Artist", 200.0),
                ("Relaxing Vibes", "Lofi Artist", 220.0),
            ],
            "jazz": [
                ("Smooth Jazz", "Jazz Artist", 180.0),
                ("Jazz Cafe", "Jazz Artist", 200.0),
                ("Late Night Jazz", "Jazz Artist", 210.0),
            ],
            "edm": [
                ("Electronic Beats", "EDM Artist", 180.0),
                ("Dance Floor", "EDM Artist", 200.0),
                ("Festival Vibes", "EDM Artist", 190.0),
            ],
            "ambient": [
                ("Ambient Soundscape", "Ambient Artist", 180.0),
                ("Peaceful Atmosphere", "Ambient Artist", 200.0),
                ("Calm Waves", "Ambient Artist", 220.0),
            ],
            "study": [
                ("Focus Music", "Study Beats", 180.0),
                ("Concentration Flow", "Study Beats", 200.0),
                ("Deep Work", "Study Beats", 190.0),
            ],
            "sleep": [
                ("Sleep Sounds", "Relaxation", 180.0),
                ("Peaceful Dreams", "Relaxation", 200.0),
                ("Night Time", "Relaxation", 220.0),
            ],
        ]
        
        // Find matching genre
        var matchedTracks = [(title: String, artist: String, duration: Double)]()
        
        for (genre, tracks) in genreMap {
            if lowercaseQuery.contains(genre) {
                matchedTracks = tracks
                print("🎵 Found genre match: \(genre)")
                break
            }
        }
        
        // If no genre match, use default chill playlist
        if matchedTracks.isEmpty {
            print("🎵 No genre match, using default chill playlist")
            matchedTracks = genreMap["lofi"] ?? []
        }
        
        // Convert to MusicTrack objects (cycle through available URLs)
        return matchedTracks.enumerated().map { index, track in
            // Cycle through all available URLs
            let urlIndex = index % urls.count
            let url = urls[urlIndex]
            
            print("🎵 Track \(index): \(track.title) → URL: \(url)")
            
            return MusicTrack(
                id: "sample-\(index)",
                title: track.title,
                artist: track.artist,
                artworkURL: nil,
                audioURL: url,
                duration: track.duration
            )
        }
    }
    
    // MARK: - Cleanup
    deinit {
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Music Intent Detection
extension MusicService {
    /// Detect if user message is requesting music
    static func detectMusicIntent(in message: String) -> MusicIntent? {
        let lowercased = message.lowercased()
        print("🔍 Checking for music intent in: \(message)")
        
        // Play music keywords
        let playKeywords = ["play", "put on", "listen to", "music", "song", "playlist"]
        let hasPlayIntent = playKeywords.contains { lowercased.contains($0) }
        
        print("🔍 playKeywords check result: \(hasPlayIntent)")
        
        if hasPlayIntent {
            // Extract music query
            let query = extractMusicQuery(from: message)
            print("🎵 Play intent detected! Query: \(query)")
            return MusicIntent(action: .play, query: query)
        }
        
        // Pause keywords - only very specific phrases to avoid false matches
        // Must be MORE specific than other intents
        let pauseKeywords = ["pause music", "pause the music", "stop playing", "stop the music"]
        if pauseKeywords.contains(where: { lowercased.contains($0) }) {
            print("⏸️ Pause intent detected")
            return MusicIntent(action: .pause, query: nil)
        }
        
        // Next/Skip keywords - use word boundaries
        let nextKeywords = ["next", "skip", "next song", "next track", "skip song"]
        if nextKeywords.contains(where: { lowercased.contains($0) }) {
            print("⏭️ Next intent detected")
            return MusicIntent(action: .next, query: nil)
        }
        
        // Previous keywords - use word boundaries
        let prevKeywords = ["previous", "back", "go back", "previous track", "previous song"]
        if prevKeywords.contains(where: { lowercased.contains($0) }) {
            print("⏮️ Previous intent detected")
            return MusicIntent(action: .previous, query: nil)
        }
        
        print("❌ No music intent detected")
        return nil
    }
    
    private static func extractMusicQuery(from message: String) -> String {
        // Simple extraction - remove common command words
        var query = message.lowercased()
        let removeWords = ["play", "put on", "listen to", "some", "music", "song", "please", "can you"]
        
        for word in removeWords {
            query = query.replacingOccurrences(of: word, with: "")
        }
        
        return query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Music Intent Model
struct MusicIntent {
    enum Action {
        case play
        case pause
        case next
        case previous
    }
    
    let action: Action
    let query: String?
}

