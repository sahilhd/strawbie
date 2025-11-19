//
//  ImageUtilityService.swift
//  DAOmates
//
//  Created by AI Assistant on 2025-11-13.
//

import UIKit
import Vision

class ImageUtilityService {
    static let shared = ImageUtilityService()
    
    private init() {}
    
    // MARK: - Image Compression
    
    /// Compress and resize image for optimal API transmission
    func compressImage(_ image: UIImage, maxWidth: CGFloat = 1024, quality: CGFloat = 0.8) -> UIImage? {
        // Calculate new size
        let scale = maxWidth / image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSize(width: maxWidth, height: newHeight)
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    // MARK: - Base64 Encoding
    
    /// Convert UIImage to Base64 string for API transmission
    func imageToBase64(_ image: UIImage) -> String? {
        guard let compressedImage = compressImage(image) else { return nil }
        guard let jpegData = compressedImage.jpegData(compressionQuality: 0.8) else { return nil }
        return jpegData.base64EncodedString()
    }
    
    /// Convert Base64 string back to UIImage
    func base64ToImage(_ base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - Image Analysis
    
    /// Analyze image content for better context in prompts
    func analyzeImageContent(_ image: UIImage, completion: @escaping (ImageAnalysis?) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            var detectedText = ""
            if let observations = request.results as? [VNRecognizedTextObservation] {
                for observation in observations {
                    if let candidate = observation.topCandidates(1).first {
                        detectedText += candidate.string + "\n"
                    }
                }
            }
            
            let analysis = ImageAnalysis(
                containsText: !detectedText.isEmpty,
                detectedText: detectedText,
                isDocument: self.isDocumentLike(image),
                isHandwritten: self.isHandwritten(detectedText)
            )
            
            completion(analysis)
        }
        
        request.recognitionLanguages = ["en-US"]
        
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
    }
    
    private func isDocumentLike(_ image: UIImage) -> Bool {
        // Simple heuristic: documents are usually portrait-oriented with aspect ratio close to 8.5x11
        let aspectRatio = image.size.width / image.size.height
        return (0.5...0.8).contains(aspectRatio)
    }
    
    private func isHandwritten(_ text: String) -> Bool {
        // Heuristic: if text detection fails or is poor, likely handwritten
        return text.count < 20 || text.contains("?") // Question marks often from OCR errors
    }
}

// MARK: - Image Analysis Model
struct ImageAnalysis {
    let containsText: Bool
    let detectedText: String
    let isDocument: Bool
    let isHandwritten: Bool
}

