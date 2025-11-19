//
//  YouTubeService.swift
//  DAOmates
//
//  Created by AI Assistant on 2025-11-15.
//

import Foundation

// MARK: - YouTube Data Models

struct YouTubeSearchResponse: Codable {
    let items: [YouTubeVideo]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
}

struct YouTubeVideo: Codable, Identifiable {
    struct VideoId: Codable, Hashable {
        let videoId: String
        
        enum CodingKeys: String, CodingKey {
            case videoId
        }
    }
    
    let id: VideoId
    let snippet: Snippet
    
    enum CodingKeys: String, CodingKey {
        case id
        case snippet
    }
    
    struct Snippet: Codable {
        let title: String
        let description: String
        let thumbnails: Thumbnails
        let channelTitle: String
        
        enum CodingKeys: String, CodingKey {
            case title
            case description
            case thumbnails
            case channelTitle
        }
    }
    
    struct Thumbnails: Codable {
        let high: Thumbnail
        
        enum CodingKeys: String, CodingKey {
            case high
        }
    }
    
    struct Thumbnail: Codable {
        let url: String
        let width: Int?
        let height: Int?
    }
}

// MARK: - YouTube Service

class YouTubeService {
    static let shared = YouTubeService()
    
    private let apiKey = AppConfig.youtubeAPIKey
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    // 🚀 Backend URL for audio stream extraction
    private let backendBaseURL = "https://strawbie-production.up.railway.app"
    
    private init() {}
    
    /// Search for music on YouTube via backend service with REAL yt-dlp extraction
    func searchMusic(query: String) async throws -> [MusicTrack] {
        print("🔍 🎵 Searching REAL YouTube music for: \(query)")
        
        guard let url = URL(string: "\(backendBaseURL)/api/search-and-extract") else {
            print("❌ Invalid backend URL")
            throw YouTubeError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // Allow time for yt-dlp extraction
        
        let body: [String: String] = ["query": query]
        request.httpBody = try JSONEncoder().encode(body)
        
        print("🎥 Calling REAL YouTube backend: \(backendBaseURL)/api/search-and-extract")
        print("📤 Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response from backend")
            throw YouTubeError.apiError
        }
        
        print("📊 Backend response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorData = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Backend API error: \(httpResponse.statusCode) - \(errorData)")
            throw YouTubeError.apiError
        }
        
        // Log raw response for debugging
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("📥 Raw backend response: \(rawResponse)")
        }
        
        let backendResponse = try JSONDecoder().decode(YouTubeBackendResponse.self, from: data)
        
        guard let audioUrl = backendResponse.audioUrl, !audioUrl.isEmpty else {
            print("⚠️ Backend did not return a playable audio URL")
            print("⚠️ Response: \(backendResponse)")
            throw YouTubeError.apiError
        }
        
        print("✅ ✅ ✅ REAL YouTube audio URL received!")
        print("🎵 Title: \(backendResponse.title ?? "Unknown")")
        print("🎵 Video ID: \(backendResponse.videoId ?? "Unknown")")
        print("🎵 Duration: \(backendResponse.duration ?? 0)s")
        print("🎵 Audio URL: \(audioUrl.prefix(100))...")
        
        // Extract artist from title (usually "Artist - Song" or "Song by Artist")
        let titleComponents = (backendResponse.title ?? query).components(separatedBy: " - ")
        let artist = titleComponents.count > 1 ? titleComponents[0] : "YouTube"
        let songTitle = titleComponents.count > 1 ? titleComponents[1] : (backendResponse.title ?? query)
        
        // Use direct YouTube audio URL (backend already extracted it)
        let videoId = backendResponse.videoId ?? ""
        
        print("🎵 Using direct YouTube audio URL")
        
        // Return as a single MusicTrack with YouTube audio
        let track = MusicTrack(
            id: videoId,
            title: songTitle,
            artist: artist,
            artworkURL: backendResponse.thumbnail,
            audioURL: audioUrl,  // Use direct YouTube URL from backend
            duration: backendResponse.duration ?? 180.0
        )
        
        print("🎵 Created MusicTrack: \(track.title) by \(track.artist)")
        
        return [track]
    }
    
    /// Get video details including duration
    func getVideoDetails(videoId: String) async throws -> (duration: Double, viewCount: String) {
        guard !apiKey.isEmpty else { throw YouTubeError.noAPIKey }
        
        let urlString = "\(baseURL)/videos?part=contentDetails,statistics&id=\(videoId)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw YouTubeError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let items = json["items"] as? [[String: Any]],
           let firstItem = items.first,
           let contentDetails = firstItem["contentDetails"] as? [String: Any],
           let durationString = contentDetails["duration"] as? String {
            
            let duration = parseISO8601Duration(durationString)
            let viewCount = (firstItem["statistics"] as? [String: Any])?["viewCount"] as? String ?? "0"
            
            return (duration, viewCount)
        }
        
        return (0, "0")
    }
    
    /// Parse ISO 8601 duration format (PT#H#M#S)
    private func parseISO8601Duration(_ duration: String) -> Double {
        let pattern = "PT(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
        
        let nsString = duration as NSString
        let results = regex.firstMatch(in: duration, range: NSRange(location: 0, length: nsString.length))
        
        var totalSeconds: Double = 0
        
        if let results = results {
            if let hoursString = nsString.substring(with: results.range(at: 1)).isEmpty ? nil : nsString.substring(with: results.range(at: 1)) {
                totalSeconds += Double(hoursString) ?? 0 * 3600
            }
            if let minutesString = nsString.substring(with: results.range(at: 2)).isEmpty ? nil : nsString.substring(with: results.range(at: 2)) {
                totalSeconds += Double(minutesString) ?? 0 * 60
            }
            if let secondsString = nsString.substring(with: results.range(at: 3)).isEmpty ? nil : nsString.substring(with: results.range(at: 3)) {
                totalSeconds += Double(secondsString) ?? 0
            }
        }
        
        return totalSeconds
    }
}

// MARK: - Backend Response Model

struct YouTubeBackendResponse: Codable {
    let audioUrl: String?
    let title: String?
    let duration: Double?
    let videoId: String?
    let thumbnail: String?
    let success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case audioUrl = "audioUrl"
        case title = "title"
        case duration = "duration"
        case videoId = "videoId"
        case thumbnail = "thumbnail"
        case success = "success"
    }
}

// MARK: - Error Types

enum YouTubeError: LocalizedError {
    case noAPIKey
    case invalidURL
    case apiError
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "YouTube API key is not configured"
        case .invalidURL:
            return "Invalid YouTube API URL"
        case .apiError:
            return "YouTube API returned an error"
        case .decodingError:
            return "Failed to decode YouTube response"
        case .networkError:
            return "Network error occurred"
        }
    }
}

