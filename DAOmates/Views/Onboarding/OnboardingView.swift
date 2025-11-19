//
//  OnboardingView.swift
//  DAOmates
//
//  Production-ready onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentPage = 0
    @State private var showAuth = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "person.3.sequence.fill",
                        title: "Meet Your Crypto DAOmates",
                        description: "Chat with AI personalities inspired by crypto legends. Get personalized advice on DeFi, NFTs, trading, and more.",
                        gradientColors: [.cyan, .purple]
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "brain.head.profile",
                        title: "Personalized AI Companions",
                        description: "Each DAOmate has unique expertise and personality. From ABG's trendy takes to Satoshi's wisdom, find your perfect match.",
                        gradientColors: [.purple, .pink]
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "lock.shield.fill",
                        title: "Secure & Private",
                        description: "Your conversations and data are protected with industry-standard encryption. Optional Face ID and wallet integration available.",
                        gradientColors: [.green, .cyan]
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Stay Ahead in Crypto",
                        description: "Get insights on market trends, learn about new protocols, and make informed decisions with AI-powered guidance.",
                        gradientColors: [.orange, .pink]
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    if currentPage < 3 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        
                        Button(action: {
                            currentPage = 3
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Button(action: {
                            authViewModel.showOnboarding = false
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let gradientColors: [Color]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.6)
                
                Image(systemName: icon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}

