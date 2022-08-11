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
    /* 제일 처음에 카메라 권한을 요청할 때는 .notDetermined상태임 그러므로 이 상태임
     그러므로 그 경우에는 권한 요청을 한번 더 해야 함
     */
    func getCameraAuthorizationStatus() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // 사용자가 카메라 권한을 승인
            return true
            
        case .notDetermined: // 카메라 권한이 아직 결정되지 아직 않은 상태(초기 상태)
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted
        case .denied: // 사용자가 권한을 거부한 상태
            return false
            
        case .restricted: // 접근 권한이 제한된 상태
            return false
            
        @unknown default: // 나중에 버전이 바뀔수도 있음
            fatalError()
        }
    }
}
