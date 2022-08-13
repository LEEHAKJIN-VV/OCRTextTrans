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
    private var captureViewController: CapturePhotoViewController?
    
    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    private var permissionManager = PermissionManager() // 권한 매니저
    // camera view -> 사진을 찍을 화면을 보여주는 뷰
    private lazy var cameraFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .black // avcapturesession이 시작되기 전에 보여줄 임시 검은색 화면
        return view
    }()
    
    // bottom container view
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    // top container view
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 캡처 버튼
    private lazy var captureButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 7
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        print("viewDidLoad call")
        self.cameraFrameView.layer.addSublayer(previewLayer)
        self.bottomContainerView.addSubview(self.captureButton)
        self.view.addSubview(topContainerView)
        self.view.addSubview(bottomContainerView)
        self.view.addSubview(cameraFrameView)
        
        self.startCamera() // 카메라 기능 시작
        captureButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside) // action method 등록
        self.navigationItem.title = "테스트"
        //self.navigationItem.hidesBackButton = true
    }
    // 뷰가 나타낼때 session 시작
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear call")
        self.startCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews call")
        super.viewDidLayoutSubviews()
        // main thread에서 화면을 송출할 layer 크기 지정
        DispatchQueue.main.async {
            self.previewLayer.frame = self.cameraFrameView.bounds
        }
        // 제약 조건
        cameraFrameView.snp.makeConstraints { make in
            make.bottom.equalTo(self.bottomContainerView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        topContainerView.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.top.equalTo(self.view.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.cameraFrameView.snp.top)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        captureButton.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.center.equalToSuperview()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear call")
        self.session?.stopRunning() // 카메라 session을 멈춤
        self.captureViewController = nil // capturephoto 프로퍼티를 nil로 초기화
    }
    // 촬영 버튼 액션 메소드
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self) // 사진을 캡처하는 메소드
    }
    
    // 카메라 시작
    func startCamera() {
        // 카메라 접근 권한을 확인 true면 승인 false면 승인이 안된 상태이므로 카메라 승인을 요청해야 함
        Task {
            let requestStatus: PermissionManager.CameraPermission = await permissionManager.getCameraAuthorizationStatus()
            switch requestStatus {
            case .authorize:
                self.setUpcamera()
                break
            case .deny:
                self.cameraDenied() // 카메라 권한이 거부된 경우
                break
            default:
                self.navigationController?.popViewController(animated: false)
                break
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
                previewLayer.session = tmpSession //
                // previewlayer의 session 설정
                self.session = tmpSession
                self.startCaptureSession()
            } catch {
                print(error)
            }
        }
    }
    private func cameraDenied() { // 카메라 권한이 거부된 경우 Alert를 생성하여 카메라 권한 설정 요청
        // alert 생성
        let alert = UIAlertController(title: StringDescription.CamPermission.title.rawValue,
                                      message:StringDescription.CamPermission.content.rawValue,
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (_) in // 카메라 권한 승인을 취소한 경우 뒤로가기
            self.navigationController?.popViewController(animated: false) // 뒤로 가기
        }
        let ok = UIAlertAction(title: "확인", style: .default) { (_) in
            let settingsURL = URL(string: UIApplication.openSettingsURLString)! // 설정 url
            if UIApplication.shared.canOpenURL(settingsURL) { // setting 앱을 열 수 있는 경우
                UIApplication.shared.open(settingsURL) // 설정 앱 열기
            }
            self.navigationController?.popViewController(animated: false)
        }
        // AlertAction 버튼 등록
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: false) // alert 열기
    }
    private func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.startRunning() // session start
        }
    }
}

// MARK: - 사진을 캡처했을 때 결과를 알리는 protocol
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        // captureViewController가 nil이 아닌경우 이미 찍은 사진이 있으므로 바로 함수 종료
        guard self.captureViewController == nil else {
            return
        }
        let image = UIImage(data: data)!
        self.session?.stopRunning() // 이미지를 캡쳐한 경우 session 종료
        
        self.captureViewController = CapturePhotoViewController(image: image)
        captureViewController?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(captureViewController!, animated: true)
    }
}

// MARK: - Swift UI preview
#if DEBUG
import SwiftUI

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    // update
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    @available(iOS 13.0, *)
    func makeUIViewController(context: Context) -> UIViewController {
        CameraViewController()
        
    }
    @available(iOS 13.0, *)
    struct ViewController_Previews: PreviewProvider {
        static var previews: some View {
            if #available(iOS 15.0, *) {
                CameraViewControllerRepresentable()
                    .previewInterfaceOrientation(.portrait)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#endif
