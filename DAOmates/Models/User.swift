//
//  User.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String // Firebase UID
    var username: String
    var email: String
    var walletAddress: String?
    var favoriteAvatars: [String] // Firebase document IDs
    var chatHistory: [ChatSession]
    var createdAt: Date
    var lastLogin: Date
    
    init(id: String = UUID().uuidString, username: String, email: String, walletAddress: String? = nil, createdAt: Date = Date(), lastLogin: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.walletAddress = walletAddress
        self.favoriteAvatars = []
        self.chatHistory = []
        self.createdAt = createdAt
        self.lastLogin = lastLogin
    }
}

struct ChatSession: Identifiable, Codable {
    var id = UUID()
    let avatarId: UUID
    let avatarName: String
    var messages: [ChatMessage]
    let createdAt: Date
    var lastMessageAt: Date
    
    init(avatarId: UUID, avatarName: String) {
        self.avatarId = avatarId
        self.avatarName = avatarName
        self.messages = []
        self.createdAt = Date()
        self.lastMessageAt = Date()
    }
}

struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let audioURL: String?
    let videoURL: String?
    let imageBase64: String?  // Base64 encoded image data for storage
    
    init(content: String, isFromUser: Bool, audioURL: String? = nil, videoURL: String? = nil, imageBase64: String? = nil) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.audioURL = audioURL
        self.videoURL = videoURL
        self.imageBase64 = imageBase64
    }
}
