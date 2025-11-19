//
//  DebugChatView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct DebugChatView: View {
    let avatar: Avatar
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Simple background
            Color.purple
                .ignoresSafeArea()
            
            VStack {
                // Simple header
                HStack {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Chat with \(avatar.name)")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                }
                .padding()
                
                // Simple avatar display
                VStack {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("ABG")
                                .foregroundColor(.white)
                                .font(.title)
                        )
                    
                    Text("This is ABG!")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                // Simple message
                Text("Debug: Chat view is working!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    DebugChatView(avatar: Avatar.sampleAvatars[0])
}
