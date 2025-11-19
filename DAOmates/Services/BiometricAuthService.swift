//
//  BiometricAuthService.swift
//  DAOmates
//
//  Face ID / Touch ID authentication
//

import Foundation
import LocalAuthentication

class BiometricAuthService {
    static let shared = BiometricAuthService()
    
    private init() {}
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    enum BiometricError: Error {
        case authenticationFailed
        case userCancel
        case userFallback
        case biometricLockout
        case biometricNotAvailable
        case biometricNotEnrolled
        case unknown
    }
    
    func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    func authenticateUser(reason: String = "Authenticate to access your account") async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Enter Password"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.biometricNotAvailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch let error as LAError {
            switch error.code {
            case .authenticationFailed:
                throw BiometricError.authenticationFailed
            case .userCancel:
                throw BiometricError.userCancel
            case .userFallback:
                throw BiometricError.userFallback
            case .biometryLockout:
                throw BiometricError.biometricLockout
            case .biometryNotAvailable:
                throw BiometricError.biometricNotAvailable
            case .biometryNotEnrolled:
                throw BiometricError.biometricNotEnrolled
            default:
                throw BiometricError.unknown
            }
        }
    }
}

