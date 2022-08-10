//
//  PermissionManager.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/10.
//

import Foundation
import AVKit

// MARK: - User의 권한을 관리하는 매니저
struct PermissionManager {
    
    func getCameraAuthorizationStatus() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return true
            
        case .notDetermined: // The user has not yet been asked for camera access.
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted
        case .denied: // The user has previously denied access.
            return false
            
        case .restricted: // The user can't grant access due to restrictions.
            return false
            
        @unknown default:
            fatalError()
        }
    }
}
