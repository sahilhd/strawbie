//
//  ContentView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if authViewModel.showOnboarding {
                // Full-screen video intro, then forms in sheet
                NavigationStack {
                    FullScreenVideoIntroView()
                }
                .transition(.opacity)
            } else if authViewModel.isAuthenticated {
                // Skip to Pocket Mode chat directly
                CleanABGHomeView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                // Not authenticated and not in onboarding
                CleanABGHomeView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.4), value: authViewModel.showOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
