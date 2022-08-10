//
//  CameraCaptureView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/10.
//

import Foundation
import AVFoundation

class CameraCaptureView {
    private var permissionManager = PermissionManager() // 권한 매니저
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    // 카메라 시작
    func startCamera() {
        Task {
            let requestStatus = await permissionManager.getCameraAuthorizationStatus()
            if requestStatus { // 카메라 권한 승인
                // add camera view
            }
        }
    }
    
    private
    
}
