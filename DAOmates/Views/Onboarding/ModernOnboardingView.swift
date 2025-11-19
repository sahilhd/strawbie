//
//  ModernOnboardingView.swift
//  DAOmates
//
//  Premium ABG-focused onboarding
//

import SwiftUI

struct ModernOnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    private let pages = [
        OnboardingPageData(
            title: "Meet ABG",
            subtitle: "Your Fashion-Forward\nCrypto Bestie",
            description: "Chat with ABG about fashion, crypto, NFTs, and everything in between. She's here to make your crypto journey stylish!",
            imageName: "abg_avatar",
            gradient: [Color.pink, Color.purple],
            icon: "sparkles"
        ),
        OnboardingPageData(
            title: "Get Style Advice",
            subtitle: "Fashion Meets\nBlockchain",
            description: "From shopping tips to crypto investments, ABG explains complex topics with style and flair. Like getting advice from your most fashionable friend!",
            gradient: [Color.purple, Color.cyan],
            icon: "bag.fill"
        ),
        OnboardingPageData(
            title: "Learn About Crypto",
            subtitle: "NFTs, DeFi & More",
            description: "Discover the world of cryptocurrency, NFTs, and DeFi with someone who makes it fun and easy to understand.",
            gradient: [Color.cyan, Color.blue],
            icon: "bitcoinsign.circle.fill"
        ),
        OnboardingPageData(
            title: "Your Journey Starts",
            subtitle: "Let's Get Started!",
            description: "Join thousands exploring crypto and fashion with ABG. Create your account and start chatting today!",
            gradient: [Color.pink, Color.orange],
            icon: "heart.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            ForEach(0..<pages.count, id: \.self) { index in
                LinearGradient(
                    colors: pages[index].gradient + [.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(currentPage == index ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        ModernOnboardingPage(
                            page: pages[index],
                            isLast: index == pages.count - 1,
                            onGetStarted: {
                                authViewModel.showOnboarding = false
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                // Skip/Next Buttons
                if currentPage < pages.count - 1 {
                    HStack {
                        Button(action: {
                            authViewModel.showOnboarding = false
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text("Next")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct OnboardingPageData {
    let title: String
    let subtitle: String
    let description: String
    var imageName: String? = nil
    let gradient: [Color]
    let icon: String
}

struct ModernOnboardingPage: View {
    let page: OnboardingPageData
    let isLast: Bool
    let onGetStarted: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon/Image
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .opacity(0.6)
                
                if let imageName = page.imageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5)] + page.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: page.gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: page.icon)
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(2)
                
                Text(page.subtitle)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
            }
            .opacity(isAnimating ? 1.0 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            if isLast {
                Button(action: onGetStarted) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding(.top, 80)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ModernOnboardingView()
        .environmentObject(AuthViewModel())
}

