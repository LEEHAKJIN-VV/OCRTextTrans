//
//  MainPage.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/09.
//  Main Screen

import Foundation
import UIKit
import SnapKit

// MARK: - Category 종류
enum CategoryKind: Int{
    case camera, album, record
}

// MARK: - MainPage
final class MainPage: UIViewController {
    private var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        // 세부적인 사항 수정 필요
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.view.addSubview(categoryStackView) // Add StackView
        self.setNavigationBarAppear() // Custom navigation Bar
        self.setCategory() // Category 생성
    }
    // 메소드 호출 시점 확인 필요!!
    override func viewDidLayoutSubviews() {
        categoryStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    // navigation bar apperacnee설정
    private func setNavigationBarAppear() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemRed
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        self.navigationItem.title = "사진 번역" // 타이틀 설정
    }
    
    // set category
    private func setCategory() {
        createCategoryImage(mode: CategoryKind.camera, bgColor: .white)
        createCategoryImage(mode: CategoryKind.album, bgColor: .white)
        createCategoryImage(mode: CategoryKind.record, bgColor: .white)
    }
    // Create select image location: 1. camera, 2. album 3. history
    private func createCategoryImage(mode: CategoryKind, bgColor: UIColor) {
        // background view
        let bgView = RoundView()
        bgView.backgroundColor = bgColor
        bgView.tag = mode.rawValue // 액션 메소드 구분을 위한 tag
        
        // bgView에 들어갈 아이콘 이미지 뷰
        let categoryIV = UIImageView()
        bgView.addSubview(categoryIV)
        
        // create tapGesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapSelectImage(_:)))
        bgView.addGestureRecognizer(tapGestureRecognizer) // enroll tap gesture
        
        // add constraint in categoryImageView
        categoryIV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150) // 크기 수정 필요
        }
        
        switch mode {
        case .camera:
            // 스택뷰 안에 들어갈 뷰 크기 설정
            bgView.snp.makeConstraints { make in
                make.width.height.equalTo(200)
            }
            categoryIV.image = UIImage(systemName: "camera.fill")
        case .album:
            categoryIV.image = UIImage(systemName: "photo.fill")
        case .record:
            categoryIV.image = UIImage(systemName: "doc.text.image")
        }
        categoryStackView.addArrangedSubview(bgView) // stack view에 등록
    }
    // category 선택 액션 메소드
    @objc func tapSelectImage(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            print("카메라 클릭")
            self.navigationController?.pushViewController(CameraViewController(), animated: true)
            //cameraCaptureview = CameraCaptureView()
            //self.present(cameraCaptureview, animated: true)
            //cameraCaptureview.startCamera()
        case 1:
            print("앨범 클릭")
        case 2:
            print("번역 기록 클릭")
        default:
            // nothing
            break
        }
    }
}

// MARK: - Swift UI preview
#if DEBUG
import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    // update
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    @available(iOS 13.0, *)
    func makeUIViewController(context: Context) -> UIViewController {
            MainNavgationController()
        
    }
    @available(iOS 13.0, *)
    struct ViewController_Previews: PreviewProvider {
        static var previews: some View {
            if #available(iOS 15.0, *) {
                ViewControllerRepresentable()
                    .previewInterfaceOrientation(.portrait)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#endif
