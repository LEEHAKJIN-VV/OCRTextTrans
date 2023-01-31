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
    case camera, album //record
}

// MARK: - MainPage
final class MainPage: UIViewController {
    private lazy var containerView: UIView = { // 루트 뷰의 서브 뷰인 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    
    private lazy var categoryStackView: UIStackView = { // 카테고리 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = Constants.backgroundColor
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
            make.bottom.top.equalTo(self.containerView).inset(150)
        }
        self.categoryStackView.spacing = 32 // spacing은 스택뷰의 서브 뷰들이 배치되고 나서 호출
    }
    
    private func setNavigationBarAppear() { // navigation bar apperacnee설정
        self.navigationItem.title = Constants.screenTitle // 타이틀 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
    }
    
    private func setCategory() { // set category
        self.createCategoryImage(mode: CategoryKind.camera)
        self.createCategoryImage(mode: CategoryKind.album)
        //self.createCategoryImage(mode: CategoryKind.record)
    }
    // Create select image location: 1. camera, 2. album 3. history
    private func createCategoryImage(mode: CategoryKind) {
        let categoryButton = UIButton()
        categoryButton.tintColor = Constants.iconColor
        categoryButton.tag = mode.rawValue
        // 버튼 이미지 최대
        categoryButton.contentHorizontalAlignment = .fill
        categoryButton.contentVerticalAlignment = .fill
        self.categoryStackView.addArrangedSubview(categoryButton) // 스택뷰에 버튼 추가
        
        categoryButton.addTarget(self, action: #selector(tapSelectImage(_:)), for: .touchUpInside) // 액션메소드 추가
        switch mode { // 버튼 이미지 설정
        case .camera:
            categoryButton.setImage(UIImage(systemName: Constants.cameraIconName), for: .normal)
        case .album:
            categoryButton.setImage(UIImage(systemName: Constants.albumIconName), for: .normal)
//        case .record:
//            categoryButton.setImage(UIImage(systemName: Constants.recordIconName), for: .normal)
        }
    }
}
// MARK: - action method
extension MainPage {
    @objc func tapSelectImage(_ sender: UIButton) { // category 선택 액션 메소드
        switch sender.tag {
        case 0:
            print("카메라 클릭")
            self.navigationController?.pushViewController(CameraViewController(), animated: true)
        case 1:
            print("앨범 클릭")
            self.navigationController?.pushViewController(PhotoSelectViewController(), animated: true)
//        case 2:
//            print("번역 기록 클릭")
        default: // nothing
            break
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let cameraIconName: String = "camera.fill"
    static let albumIconName: String = "photo.fill"
    static let recordIconName: String = "doc.text.image"
    static let screenTitle: String = "사진 번역"
    
    static let backgroundColor: UIColor = .lightGray
    static let iconColor: UIColor = .white
    static let bartintColor: UIColor = .white
}
