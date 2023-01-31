//
//  PhotoSelectViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/09/04.
//

import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: - 앨범에서 이미지를 가져오는 뷰 컨트롤러
/// phppickerviewcontroller는 단순히 읽기만 하는 경우 권한 요청이 필요 없음
class PhotoSelectViewController: UIViewController {
    private var selectedAssetIdentifiers = [String]()
    
    private lazy var windowContainerView: UIView = { // 루트 뷰 역할을 할 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private lazy var albumImageView: UIImageView = { // 앨범에서 선택한 이미지를 표시하는 뷰컨트롤러
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    private lazy var bottomContainerView: UIView = { // 하단에 위치한 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    private lazy var selectButton: UIButton = { // 이미지를 선택하는 버튼 (phppickerview controller present)
        let button = UIButton()
        button.setTitle("선택", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        self.setBarApperance() // navigation bar 설정
        // 서브 뷰
        self.view.addSubview(self.windowContainerView)
        self.windowContainerView.addSubview(self.albumImageView)
        self.windowContainerView.addSubview(self.bottomContainerView)
        self.bottomContainerView.addSubview(self.selectButton)
        // 액션 메소드
        self.selectButton.addTarget(self, action: #selector(onclickSelectImage(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        // Constranint
        self.windowContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.albumImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.bottomContainerView.snp.top)
        }
        self.bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(ScreenInfo.screenHeight/11)
        }
        self.selectButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(ScreenInfo.screenWidth / 2)
            make.center.equalToSuperview()
        }
    }
    private func setBarApperance() { // navigation bar 설정
        self.navigationItem.title = Constants.screenTitle // title 설정
        self.navigationController?.navigationBar.tintColor = Constants.bartintColor // 네비게이션 바 색상
        
        let barItem = UIBarButtonItem(title: "다음", style: .plain, target: self, action: #selector(onClickNextScreen(_:))) // 네비게이션바 오른쪽 버튼 생성
        self.navigationItem.rightBarButtonItem = barItem
    }
    private func presentPicker(filter: PHPickerFilter?) { // phppicker controller 생성
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .current
        configuration.selection = .ordered
        configuration.selectionLimit = 1
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    private func showAlert() { // 이미지를 선택하라는 aler 생성
        let alert = UIAlertController(
            title: Constants.alertTitle,
            message: Constants.alertMsg,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        self.present(alert, animated: false)
    }
}

// MARK: - action method
extension PhotoSelectViewController {
    @objc func onclickSelectImage(_ sender: Any) { // 이미지 선택 버튼 클릭
        self.presentPicker(filter: .images)
    }
    @objc func onClickNextScreen(_ sender: Any) { // 다음 화면 버튼
        guard let photoImg = self.albumImageView.image else { // 이미지가 선택되지 않은 경우 alert 보여줌
            self.showAlert()
            return
        }
        let captureViewController = CapturePhotoViewController(image: photoImg)
        captureViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(captureViewController, animated: false)
    }
}

// MARK: - PHPickerViewController
extension PhotoSelectViewController: PHPickerViewControllerDelegate {
    // 이미지를 선택하고 다음 화면 호출
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) { // 이미지가 선택되었을 때 호출
        let provider = results.first?.itemProvider
        if let itemprovider = provider ,itemprovider.canLoadObject(ofClass: UIImage.self) {
            itemprovider.loadObject(ofClass: UIImage.self) {[weak self] image, error in
                DispatchQueue.main.async {
                    self?.albumImageView.image = image as? UIImage
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 0.1 delay
            self.dismiss(animated: true)
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let screenTitle: String = "이미지 선택"
    static let alertTitle: String = "알림"
    static let alertMsg: String = "이미지를 선택해 주세요."
    
    static let backgroundColor: UIColor = .lightGray
    static let bartintColor: UIColor = .white
}
