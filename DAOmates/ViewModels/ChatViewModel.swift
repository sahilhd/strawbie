//
//  ChatViewModel.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    var avatar: Avatar?
    
    func sendUserText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMessage = ChatMessage(content: trimmed, isFromUser: true)
        sendMessage(userMessage)
    }

    func sendMessage(_ message: ChatMessage) {
        messages.append(message)
        
        // Simulate processing delay
        isProcessing = true
        
        // Generate AI response
        Task {
            await generateAIResponse(for: message.content)
        }
    }
    
    func sendMessageWithImage(_ message: ChatMessage, imageBase64: String) async {
        messages.append(message)
        
        // Add processing indicator
        isProcessing = true
        
        // Generate AI response with image
        await generateAIResponseWithImage(for: message.content, imageBase64: imageBase64)
    }
    
    private func generateAIResponseWithImage(for userMessage: String, imageBase64: String) async {
        guard let avatar = avatar else {
            isProcessing = false
            return
        }
        
        // Get AI response with vision
        do {
            let response = try await AIService.shared.getChatResponse(
                for: userMessage,
                avatar: avatar,
                chatHistory: messages,
                imageBase64: imageBase64
            )
            
            let aiMessage = ChatMessage(
                content: response,
                isFromUser: false,
                videoURL: avatar.videoName
            )
            
            messages.append(aiMessage)
        } catch {
            print("❌ Vision API error: \(error)")
            let aiMessage = ChatMessage(
                content: "I had trouble analyzing that image. Could you try again or describe it to me?",
                isFromUser: false,
                videoURL: avatar.videoName
            )
            messages.append(aiMessage)
        }
        
        isProcessing = false
    }
    
    private func generateAIResponse(for userMessage: String) async {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        guard let avatar = avatar else {
            isProcessing = false
            return
        }
        
        let response = await getAIResponse(prompt: userMessage, avatar: avatar)
        
        // ✅ USE FULL RESPONSE - No truncation for Study Mode or detailed answers
        // The AI service now handles appropriate length based on mode
        let aiMessage = ChatMessage(
            content: response,  // Use full response, not makeConcise()
            isFromUser: false,
            videoURL: avatar.videoName
        )
        
        messages.append(aiMessage)
        isProcessing = false
    }
    
    private func makeConcise(_ text: String) -> String {
        let separators: CharacterSet = CharacterSet(charactersIn: ".!?\n")
        var sentences: [String] = []
        var current = ""
        for ch in text {
            current.append(ch)
            if String(ch).rangeOfCharacter(from: separators) != nil {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { sentences.append(trimmed) }
                current = ""
                if sentences.count >= 2 { break }
            }
        }
        if sentences.isEmpty {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return String(trimmed.prefix(160))
        }
        let joined = sentences.joined(separator: " ")
        if joined.count <= 200 { return joined }
        return String(joined.prefix(200))
    }
    
    private func getAIResponse(prompt: String, avatar: Avatar) async -> String {
        do {
            let response = try await AIService.shared.getChatResponse(
                for: prompt,
                avatar: avatar,
                chatHistory: messages
            )
            return response
        } catch {
            print("AI Service error: \(error.localizedDescription)")
            // Fallback to local responses
            let responses = generateContextualResponses(for: avatar, userPrompt: prompt)
            return responses.randomElement() ?? "That's a great question! Let me think about that..."
        }
    }
    
    private func generateContextualResponses(for avatar: Avatar, userPrompt: String) -> [String] {
        let prompt = userPrompt.lowercased()
        
        switch avatar.cryptoFocus {
        case .defi:
            if prompt.contains("yield") || prompt.contains("farming") {
                return [
                    "Yield farming is fascinating! The key is understanding impermanent loss and finding sustainable APYs. Have you looked into liquidity pools lately?",
                    "Great timing! DeFi yields are evolving with new protocols launching weekly. I'd recommend starting with established platforms like Uniswap or Compound.",
                    "Yield farming can be profitable but risky. Always DYOR and never invest more than you can afford to lose. What's your risk tolerance?"
                ]
            } else if prompt.contains("protocol") || prompt.contains("defi") {
                return [
                    "DeFi protocols are revolutionizing finance! From AMMs to lending platforms, we're seeing incredible innovation. Which protocols interest you most?",
                    "The beauty of DeFi is its composability - protocols can interact like Lego blocks. This creates endless possibilities for financial products!",
                    "DeFi protocols offer transparency and permissionless access that traditional finance can't match. Have you tried any dApps recently?"
                ]
            }
            
        case .nft:
            if prompt.contains("nft") || prompt.contains("art") {
                return [
                    "NFTs are more than just JPEGs! They represent digital ownership and provenance. The art world is being transformed by blockchain technology.",
                    "The NFT space is evolving beyond profile pictures. We're seeing utility NFTs, gaming assets, and even real-world asset tokenization!",
                    "As an NFT curator, I'm excited about the intersection of creativity and technology. What type of digital art speaks to you?"
                ]
            } else if prompt.contains("market") || prompt.contains("collection") {
                return [
                    "NFT markets are maturing with better curation and discovery tools. Floor prices tell only part of the story - utility and community matter more.",
                    "Building a strong NFT collection is about finding projects with lasting value and engaged communities. Quality over quantity!",
                    "The NFT market cycles are intense, but the underlying technology and creative potential remain strong. What collections are you watching?"
                ]
            }
            
        case .trading:
            if prompt.contains("trade") || prompt.contains("market") {
                return [
                    "Trading crypto requires discipline and risk management. Never FOMO into positions - stick to your strategy and use stop losses!",
                    "Market analysis is crucial, but remember that crypto markets are highly volatile. Technical analysis helps, but fundamentals matter too.",
                    "The key to successful trading is managing emotions. Fear and greed are your biggest enemies. Have you developed a trading plan?"
                ]
            } else if prompt.contains("price") || prompt.contains("analysis") {
                return [
                    "Price predictions are tough in crypto! Focus on understanding market cycles, on-chain metrics, and project fundamentals instead.",
                    "Technical analysis can provide insights, but crypto markets are influenced by many factors - news, regulations, whale movements, and sentiment.",
                    "Remember, past performance doesn't guarantee future results. Always diversify and never invest more than you can afford to lose!"
                ]
            }
            
        case .dao:
            if prompt.contains("dao") || prompt.contains("governance") {
                return [
                    "DAOs represent the future of organizational structure! Decentralized governance allows communities to make collective decisions transparently.",
                    "Governance tokens give holders voting power, but with great power comes great responsibility. Active participation makes DAOs stronger!",
                    "The beauty of DAOs is their permissionless nature - anyone can contribute and earn governance rights. Have you participated in any DAO votes?"
                ]
            } else if prompt.contains("community") || prompt.contains("vote") {
                return [
                    "Strong communities are the backbone of successful DAOs. Engagement, transparency, and shared vision drive collective success.",
                    "Voting in DAOs is both a right and responsibility. Every vote shapes the future of the protocol and its community.",
                    "Building consensus in decentralized communities requires patience and clear communication. What governance models interest you most?"
                ]
            }
            
        case .blockchain:
            if prompt.contains("blockchain") || prompt.contains("bitcoin") {
                return [
                    "Blockchain technology is revolutionary - immutable, decentralized, and transparent. Bitcoin proved digital scarcity is possible!",
                    "The blockchain trilemma of scalability, security, and decentralization drives most innovation in this space. Each project makes tradeoffs.",
                    "Bitcoin's proof-of-work consensus mechanism is energy-intensive but provides unmatched security. The network has never been hacked!"
                ]
            } else if prompt.contains("ethereum") || prompt.contains("smart contract") {
                return [
                    "Ethereum enabled programmable money through smart contracts. This opened the door to DeFi, NFTs, and countless other applications!",
                    "Smart contracts are self-executing agreements with terms directly written into code. They remove the need for intermediaries in many cases.",
                    "Ethereum's transition to proof-of-stake reduced energy consumption by 99.95%. The merge was a historic achievement for blockchain!"
                ]
            }
            
        case .metaverse:
            if prompt.contains("metaverse") || prompt.contains("virtual") {
                return [
                    "The metaverse represents the convergence of virtual worlds, blockchain, and social interaction. We're building the internet's next evolution!",
                    "Virtual real estate and digital assets are becoming increasingly valuable as more people spend time in virtual worlds.",
                    "Interoperability between virtual worlds is crucial for the metaverse's success. Your avatar and assets should move seamlessly between platforms!"
                ]
            }
        }
        
        // Default responses based on avatar personality
        return [
            "That's an interesting perspective! \(avatar.personality.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? "I'd love to explore that further.").",
            "Great question about \(avatar.cryptoFocus.rawValue.lowercased())! My experience in \(avatar.specialization.lowercased()) tells me this is worth discussing.",
            "\(avatar.name) here! Based on my focus on \(avatar.cryptoFocus.rawValue.lowercased()), I think there's more to unpack in your question."
        ]
    }
    
    /// Clear all chat messages and reset to fresh state
    func clearChat() {
        messages.removeAll()
        isProcessing = false
        print("🗑️ Chat cleared - starting fresh conversation")
    }
}
