//
//  Outfit.swift
//  DAOmates
//
//  Created by Assistant on 2025-09-03.
//

import Foundation

struct Outfit: Identifiable, Codable {
    var id = UUID()
    let name: String
    let description: String
    let videoFileName: String
    let thumbnailName: String?
    let category: OutfitCategory
    let isUnlocked: Bool
    
    enum OutfitCategory: String, CaseIterable, Codable {
        case pocket = "Pocket"
        case chill = "Chill"
        case study = "Study"
        case sleep = "Sleep"
    }
}

extension Outfit {
    static let sampleOutfits = [
        Outfit(
            name: "Pocket Mode",
            description: "Always down to chat",
            videoFileName: "pocketmode.mp4",
            thumbnailName: "pocketmode",
            category: .pocket,
            isUnlocked: true
        ),
        Outfit(
            name: "Chill Vibes",
            description: "Relaxed and easy",
            videoFileName: "chillmode.mp4",
            thumbnailName: "chillmode",
            category: .chill,
            isUnlocked: true
        ),
        Outfit(
            name: "Study Mode",
            description: "Ready to focus",
            videoFileName: "studymode.mp4",
            thumbnailName: "studymode",
            category: .study,
            isUnlocked: true
        ),
        Outfit(
            name: "Sleep Time",
            description: "Cozy and comfy",
            videoFileName: "sleepmode.mp4",
            thumbnailName: "sleepmode",
            category: .sleep,
            isUnlocked: true
        )
    ]
    
    // Function to get available outfits
    static func getAvailableOutfits() -> [Outfit] {
        var availableOutfits: [Outfit] = []
        
        // Add the default outfit (current video) - always available
        availableOutfits.append(sampleOutfits[0])
        
        // Add sample outfits for demonstration (you can remove these later)
        availableOutfits.append(contentsOf: sampleOutfits.dropFirst())
        
        // Check for outfit videos in the outfits folder (if it exists in bundle)
        if let outfitsPath = Bundle.main.path(forResource: "outfits", ofType: nil) {
            do {
                let outfitFiles = try FileManager.default.contentsOfDirectory(atPath: outfitsPath)
                
                for fileName in outfitFiles where fileName.hasSuffix(".mov") || fileName.hasSuffix(".mp4") {
                    let outfitName = fileName.replacingOccurrences(of: ".mov", with: "").replacingOccurrences(of: ".mp4", with: "")
                    
                    let outfit = Outfit(
                        name: outfitName.capitalized.replacingOccurrences(of: "_", with: " "),
                        description: "Custom outfit style",
                        videoFileName: fileName,
                        thumbnailName: nil,
                        category: .pocket,
                        isUnlocked: true
                    )
                    
                    availableOutfits.append(outfit)
                }
            } catch {
                print("Could not read outfits directory: \(error)")
            }
        }
        
        return availableOutfits
    }
}
