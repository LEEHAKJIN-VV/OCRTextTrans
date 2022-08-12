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
    // 루트 뷰의 서브 뷰인 컨테이너 뷰
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()
    // 카테고리 스택 뷰
    private var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .yellow
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView) // rootview에 containerview 추가
        self.containerView.addSubview(categoryStackView) // containerview에 stackview 추가
        self.setNavigationBarAppear() // Custom navigation Bar
        self.setCategory() // Category 생성
    }
    
    override func viewDidLayoutSubviews() {
        // screen안의 content들의 constraint 설정
        self.containerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalTo(self.view)
        }

        self.categoryStackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.containerView).inset(100)
            make.bottom.top.equalTo(self.containerView).inset(100)
        }
        categoryStackView.spacing = 32 // spacing은 스택뷰의 서브 뷰들이 배치되고 나서 호출
    }
    // category 선택 액션 메소드
    @objc func tapSelectImage(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            print("카메라 클릭")
            self.navigationController?.pushViewController(CameraViewController(), animated: true)
        case 1:
            print("앨범 클릭")
        case 2:
            print("번역 기록 클릭")
        default:
            // nothing
            break
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
        // 이미지 뷰
        let categoryIV = UIImageView()
        categoryIV.backgroundColor = bgColor
        categoryIV.tag = mode.rawValue
        categoryIV.isUserInteractionEnabled = true
        categoryStackView.addArrangedSubview(categoryIV) // 스택뷰의 서브 뷰로 이미지 뷰 추가
        
        // create tapGesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(tapSelectImage(_:)))
        categoryIV.addGestureRecognizer(tapGestureRecognizer) // enroll tap gesture
        // 카테고리의 이미지 설정
        switch mode {
        case .camera:
            categoryIV.image = UIImage(systemName: "camera.fill")
        case .album:
            categoryIV.image = UIImage(systemName: "photo.fill")
        case .record:
            categoryIV.image = UIImage(systemName: "doc.text.image")
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
