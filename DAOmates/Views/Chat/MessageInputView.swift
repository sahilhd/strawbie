//
//  MessageInputView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    @Binding var isRecording: Bool
    let onSendMessage: () -> Void
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    
    @State private var micScale: CGFloat = 1.0
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 12) {
                // Voice input button
                Button(action: {
                    if isRecording {
                        onStopRecording()
                    } else {
                        onStartRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.cyan.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .scaleEffect(micScale)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isRecording ? .white : .cyan)
                    }
                }
                .onAppear {
                    if isRecording {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            micScale = 1.2
                        }
                    }
                }
                .onChange(of: isRecording) {
                    if isRecording {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            micScale = 1.2
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            micScale = 1.0
                        }
                    }
                }
                
                // Text input field
                HStack {
                    TextField("Type your message...", text: $messageText, axis: .vertical)
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...4)
                        .onSubmit {
                            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSendMessage()
                            }
                        }
                    
                    if !messageText.isEmpty {
                        Button(action: {
                            messageText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.1))
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
                
                // Send button
                Button(action: onSendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            messageText: .constant(""),
            isRecording: .constant(false),
            onSendMessage: {},
            onStartRecording: {},
            onStopRecording: {}
        )
    }
    .background(Color.black)
}
