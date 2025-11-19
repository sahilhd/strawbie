//
//  BirthdayVerificationView.swift
//  DAOmates
//
//  Age verification (13+, 18+, 21+)
//

import SwiftUI

struct BirthdayVerificationView: View {
    @Environment(\.dismiss) var dismiss
    let userName: String
    let email: String
    
    @State private var selectedDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var ageGroup = "13-17" // Default
    
    var canContinue: Bool {
        let age = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year ?? 0
        return age >= 13
    }
    
    var ageVerificationText: String {
        let age = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year ?? 0
        
        if age < 13 {
            return "❌ Must be 13+ to use Strawbie"
        } else if age < 18 {
            return "✅ Access: General Features"
        } else if age < 21 {
            return "✅ Access: General + Mature Features"
        } else {
            return "✅ Access: All Features"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.1),
                    Color(red: 0.15, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.0, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Verify Age")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // Progress indicator
                VStack(spacing: 6) {
                    Text("Step 4 of 5")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.pink)
                                .frame(width: geo.size.width * 0.8)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Info section
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.cyan)
                                
                                Text("We need to verify your age to ensure you can access all appropriate features.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Birthday picker
                        VStack(spacing: 12) {
                            Text("What's your birthday?")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .foregroundColor(.pink)
                            .tint(.pink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // Age verification info
                        VStack(spacing: 12) {
                            HStack {
                                Text(ageVerificationText)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(canContinue ? .green : .red)
                                
                                Spacer()
                            }
                            
                            if canContinue {
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.open.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.green)
                                        Text("Access: General Features")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    let age = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year ?? 0
                                    if age >= 18 {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lock.open.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.green)
                                            Text("Access: Mature Features (18+)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    
                                    if age >= 21 {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lock.open.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.green)
                                            Text("Access: Premium Features (21+)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.1))
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Continue button
                NavigationLink(
                    destination: NotificationPreferenceView(userName: userName, email: email)
                        .navigationBarBackButtonHidden(true)
                ) {
                    Button(action: {}) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canContinue ? Color.pink : Color.white.opacity(0.3))
                            )
                    }
                    .disabled(!canContinue)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    BirthdayVerificationView(userName: "Bestie", email: "bestie@example.com")
}

