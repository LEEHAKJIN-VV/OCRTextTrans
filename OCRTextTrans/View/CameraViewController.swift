//
//  CameraViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/11.
//
import Foundation
import AVFoundation
import UIKit
import SnapKit

class CameraViewController: UIViewController {
    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    // 캡처 버튼
    private let captureButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 7
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    private var permissionManager = PermissionManager() // 권한 매니저
    
    override func viewDidLoad() {
        self.view.backgroundColor = .black // 카메라 뷰 배경 색
        self.view.layer.addSublayer(previewLayer) // 카메라 capture flow 뷰
        self.view.addSubview(captureButton) // 캡처 버튼
        self.startCamera() // 카메라 기능 시작
        
        captureButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside) // action method 등록
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = self.view.bounds // 카메라 송출 화면 frame 조정
        
        captureButton.snp.makeConstraints { make in // 캡처 버튼 만듬. (사이즈, 모양 위치 조정 필요)
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom).inset(40)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.session?.stopRunning() // 카메라 session을 멈춤
    }
    // 촬영 버튼 액션 메소드
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self) // 사진을 캡처하는 메소드
    }
    
    // 카메라 시작
    func startCamera() {
        // 카메라 접근 권한을 확인 true면 승인 false면 승인이 안된 상태이므로 카메라 승인을 요청해야 함
        Task {
            let requestStatus = await permissionManager.getCameraAuthorizationStatus()
            if requestStatus { // 카메라 권한 승인
                self.setUpcamera()
            } else { // 권한을 재 요청하는 alert 생성
                
            }
        }
    }
    // 카메라 셋팅
    private func setUpcamera() {
        // 임시 session 생성
        let tmpSession = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video) { // 기본 카메라 장치 가져옴 (기본: builtInWideAngleCamera)
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if tmpSession.canAddInput(input) { // input을 사용할 수 있는 경우
                    tmpSession.addInput(input)
                }
                
                if tmpSession.canAddOutput(output) { // output을 사용할 수 있는 경우
                    tmpSession.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill // video 비율
                previewLayer.connection?.videoOrientation = .portrait // 비디오 방향
                previewLayer.session = tmpSession // previewlayer의 session 설정
                
                tmpSession.startRunning() // block method
                self.session = tmpSession
                
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - 사진을 캡처했을 때 결과를 알리는 protocol
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        self.session?.stopRunning() // 이미지를 캡쳐한 경우 session 종료
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = self.view.bounds
        
        view.addSubview(imageView) // 임시로 화면에 표시
    }
}
