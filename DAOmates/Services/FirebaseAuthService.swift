//
//  FirebaseAuthService.swift
//  DAOmates
//
//  Mock Authentication for UI Development
//  When ready for production, uncomment Firebase code below
//

import Foundation

// MARK: - 🚧 PRODUCTION CODE COMMENTED FOR DEV
// Uncomment these imports when ready to use Firebase
// import FirebaseAuth
// import FirebaseFirestore

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    // MARK: - 🚧 PRODUCTION: Firebase instances
    // Uncomment when ready to use Firebase
    // private let auth = Auth.auth()
    // private let db = Firestore.firestore()
    
    private init() {
        // MARK: - 🚧 PRODUCTION: Auth state listener
        // Uncomment when ready to use Firebase
        // auth.addStateDidChangeListener { [weak self] _, user in
        //     print("🔐 Auth state changed: \(user?.email ?? "no user")")
        // }
        
        print("🛠️ DEV MODE: Using mock authentication")
    }
    
    // MARK: - 🛠️ MOCK Authentication (For Development)
    // This simulates Firebase behavior without requiring Firebase setup
    
    func signUp(email: String, password: String, username: String, walletAddress: String?) async throws -> User {
        // Simple validation
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw AuthError.invalidInput("Please fill in all required fields")
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 8 else {
            throw AuthError.weakPassword("Password must be at least 8 characters")
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create mock user with String ID (compatible with Firebase structure)
        let user = User(
            id: UUID().uuidString, // Mock Firebase UID
            username: username,
            email: email,
            walletAddress: walletAddress,
            createdAt: Date(),
            lastLogin: Date()
        )
        
        print("✅ Mock user created: \(email)")
        return user
        
        /* MARK: - 🚧 PRODUCTION: Real Firebase Sign Up
        // Uncomment when ready to use Firebase
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            
            let user = User(
                id: uid,
                username: username,
                email: email,
                walletAddress: walletAddress,
                createdAt: Date(),
                lastLogin: Date()
            )
            
            try await db.collection("users").document(uid).setData([
                "id": uid,
                "username": username,
                "email": email,
                "walletAddress": walletAddress ?? "",
                "createdAt": Timestamp(date: user.createdAt),
                "lastLogin": Timestamp(date: user.lastLogin)
            ])
            
            print("✅ User created successfully: \(email)")
            return user
            
        } catch let error as NSError {
            print("❌ Sign up error: \(error.localizedDescription)")
            
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw AuthError.emailAlreadyInUse
            } else if error.code == AuthErrorCode.weakPassword.rawValue {
                throw AuthError.weakPassword("Password is too weak")
            } else if error.code == AuthErrorCode.networkError.rawValue {
                throw AuthError.networkError
            } else {
                throw AuthError.firebaseError(error.localizedDescription)
            }
        }
        */
    }
    
    func signIn(email: String, password: String) async throws -> User {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput("Please enter email and password")
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Create mock user for development
        let user = User(
            id: UUID().uuidString,
            username: "DevUser",
            email: email,
            walletAddress: nil,
            createdAt: Date(),
            lastLogin: Date()
        )
        
        print("✅ Mock user signed in: \(email)")
        return user
        
        /* MARK: - 🚧 PRODUCTION: Real Firebase Sign In
        // Uncomment when ready to use Firebase
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let uid = authResult.user.uid
            
            let snapshot = try await db.collection("users").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                throw AuthError.userNotFound
            }
            
            try await db.collection("users").document(uid).updateData([
                "lastLogin": Timestamp(date: Date())
            ])
            
            let user = User(
                id: data["id"] as? String ?? uid,
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? email,
                walletAddress: data["walletAddress"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                lastLogin: Date()
            )
            
            print("✅ User signed in: \(email)")
            return user
            
        } catch let error as NSError {
            print("❌ Sign in error: \(error.localizedDescription)")
            
            if error.code == AuthErrorCode.userNotFound.rawValue ||
               error.code == AuthErrorCode.wrongPassword.rawValue {
                throw AuthError.wrongPassword
            } else if error.code == AuthErrorCode.networkError.rawValue {
                throw AuthError.networkError
            } else {
                throw AuthError.firebaseError(error.localizedDescription)
            }
        }
        */
    }
    
    func signOut() async throws {
        print("✅ Mock user signed out")
        
        /* MARK: - 🚧 PRODUCTION: Real Firebase Sign Out
        // Uncomment when ready to use Firebase
        do {
            try auth.signOut()
            print("✅ User signed out")
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
            throw AuthError.firebaseError(error.localizedDescription)
        }
        */
    }
    
    func resetPassword(email: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        print("✅ Mock password reset email sent to: \(email)")
        
        /* MARK: - 🚧 PRODUCTION: Real Firebase Password Reset
        // Uncomment when ready to use Firebase
        do {
            try await auth.sendPasswordReset(withEmail: email)
            print("✅ Password reset email sent to: \(email)")
        } catch {
            print("❌ Password reset error: \(error.localizedDescription)")
            throw AuthError.firebaseError(error.localizedDescription)
        }
        */
    }
    
    func getCurrentUser() async -> User? {
        // Mock: Return nil so user must login (good for testing auth flow)
        print("ℹ️ Mock: No current user (login required)")
        return nil
        
        /* MARK: - 🚧 PRODUCTION: Get Current Firebase User
        // Uncomment when ready to use Firebase
        guard let firebaseUser = auth.currentUser else {
            print("ℹ️ No Firebase user found")
            return nil
        }
        
        do {
            let snapshot = try await db.collection("users").document(firebaseUser.uid).getDocument()
            
            guard let data = snapshot.data() else {
                print("⚠️ User document not found in Firestore")
                return nil
            }
            
            let user = User(
                id: data["id"] as? String ?? firebaseUser.uid,
                username: data["username"] as? String ?? "",
                email: data["email"] as? String ?? firebaseUser.email ?? "",
                walletAddress: data["walletAddress"] as? String,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                lastLogin: (data["lastLogin"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            print("✅ Current user loaded: \(user.email)")
            return user
            
        } catch {
            print("❌ Error loading user: \(error.localizedDescription)")
            return nil
        }
        */
    }
    
    func updateProfile(userId: String, username: String?, walletAddress: String?) async throws {
        print("✅ Mock profile updated for user: \(userId)")
        
        /* MARK: - 🚧 PRODUCTION: Update Firebase Profile
        // Uncomment when ready to use Firebase
        var updateData: [String: Any] = [:]
        
        if let username = username {
            updateData["username"] = username
        }
        
        if let walletAddress = walletAddress {
            updateData["walletAddress"] = walletAddress
        }
        
        guard !updateData.isEmpty else { return }
        
        try await db.collection("users").document(userId).updateData(updateData)
        print("✅ Profile updated for user: \(userId)")
        */
    }
    
    func deleteAccount() async throws {
        print("✅ Mock account deleted")
        
        /* MARK: - 🚧 PRODUCTION: Delete Firebase Account
        // Uncomment when ready to use Firebase
        guard let currentUser = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            let uid = currentUser.uid
            
            // Delete user data from Firestore
            try await db.collection("users").document(uid).delete()
            
            // Delete Firebase Auth user
            try await currentUser.delete()
            
            print("✅ Account deleted successfully")
        } catch {
            print("❌ Delete account error: \(error.localizedDescription)")
            throw AuthError.firebaseError(error.localizedDescription)
        }
        */
    }
    
    // MARK: - Private Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidInput(String)
    case invalidEmail
    case weakPassword(String)
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case networkError
    case firebaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return message
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword(let message):
            return message
        case .wrongPassword:
            return "Incorrect email or password"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .networkError:
            return "Network error. Please check your connection"
        case .firebaseError(let message):
            return message
        }
    }
}
