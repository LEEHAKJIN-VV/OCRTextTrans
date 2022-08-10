//
//  MainPage.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/09.
//  Main Screen

import Foundation
import UIKit
import SnapKit

// MARK: - MainPage
final class MainPage: UIViewController {
    
    enum CategortKind {
        case camera
        case album
        case record
    }
    
    private var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.distribution = .fillEqually
//        stackView.snp.makeConstraints { make in
//            make.centerX.centerY.equalToSuperview()
//        }
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.view.addSubview(categoryStackView) // Add StackView
        self.setNavigationBarAppear() // Custom navigation Bar
        self.createTitle() // navigation bar title
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
    }
    // 네비게이션 타이틀 초기화
    private func createTitle() {
        var title: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 18))
            label.numberOfLines = 1
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .white
            label.text = "사진 번역"
            return label
        }()
        self.navigationItem.title = "사진 번역"
    }
    // set category
    private func setCategory() {
        createCategoryImage(mode: CategortKind.camera, bgColor: .white)
        createCategoryImage(mode: CategortKind.album, bgColor: .white)
        createCategoryImage(mode: CategortKind.record, bgColor: .white)
    }
    // Create select image location: 1. camera, 2. album 3. history
    private func createCategoryImage(mode: CategortKind, bgColor: UIColor) {
        // ContainerView로 사용할 뷰 생성
        let containerView = RoundView()
        containerView.backgroundColor = bgColor // 배경 색
        
        // containerview에 들어갈 아이콘 이미지 뷰
        let categoryIV = UIImageView()
        containerView.addSubview(categoryIV)
        
        categoryIV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
        
        switch mode {
        case .camera:
            // 스택뷰 안에 들어갈 뷰 크기 설정
            containerView.snp.makeConstraints { make in
                make.width.height.equalTo(200)
            }
            categoryIV.image = UIImage(systemName: "camera.fill")
        case .album:
            categoryIV.image = UIImage(systemName: "photo.fill")
        case .record:
            categoryIV.image = UIImage(systemName: "doc.text.image")
        }
        categoryStackView.addArrangedSubview(containerView)
    }
}

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
