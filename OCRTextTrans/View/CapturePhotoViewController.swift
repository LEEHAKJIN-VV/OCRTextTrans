//
//  CapturePhotoViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/11.
//
import Foundation
import UIKit
import SnapKit
import CropViewController

// MARK: - 카메라로 사진을 찍은 뒤 결과를 보여주는 메소드
class CapturePhotoViewController: UIViewController {
    private var captureIV: UIImageView! // 찍은 사진을 보여주는 이미지 뷰
    private lazy var bottomContainerView: UIView = { // 하단 뷰
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var bottomStackView: UIStackView = { // 하단 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 32
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .red
        return stackView
    }()
    
    private lazy var cropBtn: UIButton = { // 자르기 버튼
        let button = UIButton()
        button.setTitle("자르기", for: .normal)
        return button
    }()
    
    private lazy var reCaptureBtn: UIButton = { // 다시 찍기 버튼
        let button = UIButton()
        button.setTitle("다시 찍기", for: .normal)
        return button
    }()
    
    private lazy var transBtn: UIButton = { // 번역 버튼
        let button = UIButton()
        button.setTitle("번역", for: .normal)
        return button
    }()
    
    init(image: UIImage) { // 생성자: 이전 화면에서 찍은 사진을 받음
        captureIV = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 뷰 등록
        self.view.addSubview(captureIV)
        self.view.addSubview(bottomContainerView)
        // 스택 뷰안에 content 등록
        bottomStackView.addArrangedSubview(cropBtn)
        bottomStackView.addArrangedSubview(reCaptureBtn)
        bottomStackView.addArrangedSubview(transBtn)
        // 스택 뷰를 containerView에 등록
        bottomContainerView.addSubview(bottomStackView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 제약 조건
        cropBtn.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
            make.height.equalTo(100)
        }
        
        captureIV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.bottomContainerView.snp.top)
        }
        
    }
}


#if DEBUG
import SwiftUI

struct CaptureViewControllerRepresentable: UIViewControllerRepresentable {
    // update
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    @available(iOS 13.0, *)
    func makeUIViewController(context: Context) -> UIViewController {
        CapturePhotoViewController(image: UIImage(named: "screenshot") ?? UIImage())
        
    }
    @available(iOS 13.0, *)
    struct ViewController_Previews: PreviewProvider {
        static var previews: some View {
            if #available(iOS 15.0, *) {
                CaptureViewControllerRepresentable()
                    .previewInterfaceOrientation(.portrait)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#endif
