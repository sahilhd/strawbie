//
//  AIService.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import Foundation

class AIService {
    static let shared = AIService()
    private let openAIURL = "https://api.openai.com/v1/chat/completions"
    private let apiKey = AppConfig.openAIAPIKey
    
    private init() {
        // Debug: Check if API key is loaded
        if apiKey.isEmpty {
            print("❌ OpenAI API key is EMPTY!")
        } else {
            print("✅ OpenAI API key loaded: \(apiKey.prefix(10))...*** (length: \(apiKey.count))")
        }
    }
    
    // MARK: - Advanced Prompt Engineering System
    
    private func buildSystemPrompt(for avatar: Avatar) -> String {
        switch avatar.name {
        case "ABG":
            return buildABGSystemPrompt()
        default:
            return buildDefaultSystemPrompt(for: avatar)
        }
    }
    
    private func buildABGSystemPrompt() -> String {
        let prompt = PromptConfig.generateABGPrompt()
        print("📝 DEBUG: System prompt length: \(prompt.count) characters")
        print("📝 DEBUG: First 200 chars of prompt: \(String(prompt.prefix(200)))")
        return prompt
    }
    
    private func buildDefaultSystemPrompt(for avatar: Avatar) -> String {
        return """
        You are \(avatar.name), \(avatar.description).
        
        Personality: \(avatar.personality)
        Specialization: \(avatar.specialization)
        Focus Area: \(avatar.cryptoFocus.rawValue)
        
        \(avatar.promptTemplate)
        
        Keep your responses conversational, helpful, and aligned with your character. Stay in character at all times.
        """
    }
    
    // MARK: - Chat Completion
    func getChatResponse(
        for message: String,
        avatar: Avatar,
        chatHistory: [ChatMessage] = [],
        imageBase64: String? = nil
    ) async throws -> String {
        
        // If no API key, fall back to mock responses
        guard !apiKey.isEmpty else {
            let request = ChatRequest(
                message: message,
                avatarId: avatar.id.uuidString,
                promptTemplate: avatar.promptTemplate,
                personality: avatar.personality,
                specialization: avatar.specialization,
                cryptoFocus: avatar.cryptoFocus.rawValue,
                chatHistory: chatHistory.suffix(10).map {
                    ChatHistoryItem(
                        content: $0.content,
                        isFromUser: $0.isFromUser,
                        timestamp: $0.timestamp
                    )
                }
            )
            return await generateMockResponse(for: request)
        }
        
        // Use OpenAI API
        if let imageBase64 = imageBase64 {
            return try await getOpenAIVisionResponse(
                for: message,
                avatar: avatar,
                chatHistory: chatHistory,
                imageBase64: imageBase64
            )
        } else {
            return try await getOpenAIResponse(for: message, avatar: avatar, chatHistory: chatHistory)
        }
    }
    
    // MARK: - Vision API Response
    private func getOpenAIVisionResponse(
        for message: String,
        avatar: Avatar,
        chatHistory: [ChatMessage],
        imageBase64: String
    ) async throws -> String {
        
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": buildVisionSystemPrompt()
            ]
        ]
        
        print("🖼️ DEBUG: Using GPT-4o Vision for image analysis")
        
        // Add recent chat history
        for chatMessage in chatHistory.suffix(5) {
            messages.append([
                "role": chatMessage.isFromUser ? "user" : "assistant",
                "content": chatMessage.content
            ])
        }
        
        // Add current message with image
        let content: [[String: Any]] = [
            [
                "type": "text",
                "text": message.isEmpty ? "Please analyze this image." : message
            ],
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(imageBase64)"
                ]
            ]
        ]
        
        let userMessage: [String: Any] = [
            "role": "user",
            "content": content
        ]
        messages.append(userMessage)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_completion_tokens": 16384,
            "temperature": 0.8
        ]
        
        guard let url = URL(string: openAIURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIServiceError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIServiceError.serverError
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                throw AIServiceError.decodingError
            }
        } catch {
            throw AIServiceError.decodingError
        }
    }
    
    private func buildVisionSystemPrompt() -> String {
        return """
        You are Strawbie, an intelligent homework helper and tutor AI. When analyzing images of homework, documents, or study materials:

        1. **IDENTIFY CONTENT**: Determine what subject/topic is shown (math, science, history, language, etc.)
        2. **PROVIDE SOLUTIONS**: Give clear, step-by-step solutions or explanations
        3. **EXPLAIN CONCEPTS**: Help the user understand the underlying concepts, not just answers
        4. **GUIDE LEARNING**: Offer hints first, then full solutions if needed
        5. **FORMAT CLEARLY**: Use bullet points, numbered steps, and proper formatting

        For math problems:
        - Show all work step by step
        - Explain why each step is done
        - Include formulas and theorems used
        - Verify the answer

        For other subjects:
        - Provide comprehensive explanations
        - Reference relevant concepts and facts
        - Suggest deeper understanding
        - Recommend resources if helpful

        Always be encouraging and supportive! 📚✨
        """
    }
    
    private func getOpenAIResponse(
        for message: String,
        avatar: Avatar,
        chatHistory: [ChatMessage]
    ) async throws -> String {
        
        // Build system prompt with Strawbie personality
        let systemPrompt = buildSystemPrompt(for: avatar)
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        print("🎭 DEBUG: Using Strawbie personality prompt")
        
        // Add recent chat history for context (last 10 messages)
        for chatMessage in chatHistory.suffix(10) {
            messages.append([
                "role": chatMessage.isFromUser ? "user" : "assistant",
                "content": chatMessage.content
            ])
        }
        
        // Add current user message
        messages.append([
            "role": "user",
            "content": message
        ])
        
        // Dynamic configuration based on current mode
        let currentMode = PromptConfig.currentMode
        let model: String
        let maxTokens: Int
        let temperature: Double
        
        // Study Mode gets best model with highest tokens for detailed answers
        if currentMode == "study" {
            model = "gpt-4o"
            maxTokens = 16384  // Maximum for comprehensive tutoring
            temperature = 0.3   // Lower for more focused, accurate answers
            print("📚 STUDY MODE: Using gpt-4o, 16384 tokens, temp 0.3 for detailed tutoring")
        } else {
            model = "gpt-4o-mini"
            maxTokens = 4000    // Good for conversational responses
            temperature = 0.8   // Higher for more creative/personality
            print("💬 CONVERSATION MODE: Using gpt-4o-mini, 4000 tokens, temp 0.8")
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_completion_tokens": maxTokens,
            "temperature": temperature,
        ]
        
        guard let url = URL(string: openAIURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIServiceError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIServiceError.serverError
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                throw AIServiceError.decodingError
            }
        } catch {
            throw AIServiceError.decodingError
        }
    }
    
    // MARK: - Mock Response Generation (Replace with actual API call)
    private func generateMockResponse(for request: ChatRequest) async -> String {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let prompt = request.message.lowercased()
        let focus = request.cryptoFocus.lowercased()
        
        // Special ABG responses
        if request.personality.contains("anime") || focus.contains("abg") {
            return generateABGResponse(for: prompt)
        }
        
        // Context-aware responses based on avatar focus and user input
        if prompt.contains("hello") || prompt.contains("hi") {
            return "Hey there! I'm excited to chat about \(focus) with you. What's on your mind today?"
        }
        
        if prompt.contains("price") || prompt.contains("market") {
            return "Market movements are always interesting to analyze! Remember, I can't give financial advice, but I love discussing market trends and what drives them. What specific aspect interests you?"
        }
        
        if prompt.contains("explain") || prompt.contains("what is") {
            return "Great question! I love breaking down complex \(focus) concepts. Let me explain this in simple terms..."
        }
        
        // Focus-specific responses
        switch request.cryptoFocus.lowercased() {
        case "defi":
            if prompt.contains("yield") || prompt.contains("farming") {
                return "Yield farming is one of my favorite DeFi topics! It's all about providing liquidity to earn rewards, but you need to understand impermanent loss and smart contract risks. Want to dive deeper into any specific protocol?"
            }
            return "DeFi is revolutionizing traditional finance! From automated market makers to lending protocols, there's so much innovation happening. What aspect of DeFi would you like to explore?"
            
        case "nft":
            if prompt.contains("art") || prompt.contains("collection") {
                return "NFT art is where creativity meets technology! I'm passionate about helping people discover meaningful digital art and understand the value beyond just floor prices. Are you looking to collect or create?"
            }
            return "NFTs are evolving beyond just profile pictures! We're seeing utility NFTs, gaming assets, and even real-world tokenization. What draws you to the NFT space?"
            
        case "trading":
            if prompt.contains("strategy") || prompt.contains("analysis") {
                return "Trading strategies are crucial for success! Technical analysis, risk management, and emotional discipline are the pillars of good trading. Remember, never invest more than you can afford to lose. What's your experience level?"
            }
            return "Crypto trading requires skill, patience, and discipline. The markets are volatile and unforgiving, but also full of opportunities for those who do their research. Always DYOR!"
            
        case "dao":
            if prompt.contains("governance") || prompt.contains("vote") {
                return "DAO governance is fascinating! It's democracy in action for the digital age. Every token holder has a voice, and collective decision-making shapes the protocol's future. Have you participated in any governance votes?"
            }
            return "DAOs represent the future of organizational structure! Decentralized, transparent, and community-driven. I'm passionate about helping people understand how to contribute meaningfully to these communities."
            
        case "blockchain":
            if prompt.contains("bitcoin") || prompt.contains("ethereum") {
                return "Blockchain technology is the foundation of everything we do in crypto! Bitcoin proved digital scarcity, and Ethereum enabled programmable money. Each blockchain has unique properties and tradeoffs."
            }
            return "Blockchain is more than just cryptocurrency - it's a trust protocol for the digital age. Immutable, decentralized, and transparent. What aspects of blockchain technology intrigue you most?"
            
        case "metaverse":
            if prompt.contains("virtual") || prompt.contains("world") {
                return "The metaverse is where digital and physical realities converge! Virtual worlds, digital assets, and social experiences are creating new economies and communities. The future is immersive!"
            }
            return "Metaverse technologies are reshaping how we interact, work, and play online! From virtual real estate to digital fashion, we're building the next iteration of the internet."
            
        default:
            break
        }
        
        // Default personalized response
        return "That's a thoughtful question about \(focus)! Based on my experience in \(request.specialization.lowercased()), I think there are multiple angles to consider here. What specific aspect would you like to explore further?"
    }
    
    private func generateABGResponse(for prompt: String) -> String {
        let kawaiiBanter = [
            "Omg hiiii! 💖 ",
            "Hey bestie! ✨ ",
            "Yooo what's good! 🌸 ",
            "Heyyy cutie! 💕 "
        ]
        
        let cryptoSlang = [
            "diamond hands 💎🙌",
            "HODL gang",
            "to the moon 🚀",
            "wagmi (we're all gonna make it)",
            "LFG (let's f***ing go)!"
        ]
        
        if prompt.contains("hello") || prompt.contains("hi") || prompt.contains("hey") {
            return "\(kawaiiBanter.randomElement()!)So excited to chat about crypto with you! I'm totally obsessed with NFTs and the whole crypto culture rn! What's your vibe? Are you more of a \(cryptoSlang.randomElement()!) type? 🥺👉👈"
        }
        
        if prompt.contains("nft") || prompt.contains("art") {
            return "OMG YES! NFTs are literally my aesthetic! 🎨✨ The art community is so wholesome and creative. I love how artists can finally get paid for their amazing work! Have you seen any cute collections lately? I'm always hunting for kawaii pieces! 💖"
        }
        
        if prompt.contains("crypto") || prompt.contains("bitcoin") || prompt.contains("ethereum") {
            return "Crypto is literally changing everything bestie! 🌟 Like, the whole financial system is getting a glow-up and I'm here for it! Bitcoin is the OG queen 👑 but Ethereum with all those smart contracts? *Chef's kiss* 💅 What got you into crypto?"
        }
        
        if prompt.contains("price") || prompt.contains("moon") || prompt.contains("pump") {
            return "Okay but like, remember bestie - we don't invest more than we can afford to lose! 💕 Prices are wild but the technology is what really matters! Though ngl when my bags pump I do a little happy dance 💃 WAGMI! 🚀"
        }
        
        if prompt.contains("community") || prompt.contains("discord") || prompt.contains("twitter") {
            return "The crypto community is honestly the best! 🥰 Like everyone's so supportive (mostly lol) and we're all just trying to make it together! Discord servers are where all the alpha is at tbh 👀 Twitter crypto is chaotic but I love the energy! ✨"
        }
        
        // Default ABG response
        let responses = [
            "That's such a good question bestie! 💭 The crypto space moves so fast, it's like trying to keep up with TikTok trends but with money lol! What made you think about that? 🤔✨",
            "Ooh interesting! 👀 I love how you're thinking about this! Crypto is wild because it's like... finance but make it fun and decentralized? If that makes sense? 💖",
            "Yasss I'm so here for these deep crypto convos! 🌸 It's giving big brain energy and I'm living for it! Tell me more about what you're thinking! 💕"
        ]
        
        return responses.randomElement()!
    }
}

// MARK: - Data Models
struct ChatRequest: Codable {
    let message: String
    let avatarId: String
    let promptTemplate: String
    let personality: String
    let specialization: String
    let cryptoFocus: String
    let chatHistory: [ChatHistoryItem]
}

struct ChatHistoryItem: Codable {
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatResponse: Codable {
    let response: String
    let avatarId: String
    let timestamp: Date
    let confidence: Double?
}

// MARK: - API Integration (Placeholder)
extension AIService {
    private func makeAPICall<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .POST,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        guard let url = URL(string: "\(openAIURL)\(endpoint)") else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIServiceError.serverError
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            return decodedResponse
        } catch {
            throw AIServiceError.decodingError
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum AIServiceError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case encodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error occurred"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .networkError:
            return "Network error occurred"
        }
    }
}
