//
//  TextRecognizerView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/23.
//

import Foundation
import UIKit
import SnapKit

// MARK: - 이미지에서 텍스트를 인식한 후 이를 보여주는 뷰 컨트롤러, 텍스트를 추출하는 모델 코드 추가 예정
class TextRecognizerView: UIViewController {
    private var ocrModel: OCRModel? // 이미지에서 텍스트를 추출하는 모델
    
    private lazy var containerView: UIView = { // root view 역할을 하는 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private lazy var ocrIV: UIImageView = { // ocr된 이미지를 나타내는 이미지 뷰
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var transButton: UIButton = { // 추출한 텍스트를 번역하는 버튼
        let button = UIButton()
        button.setTitle("번역", for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
        self.containerView.addSubview(ocrIV)
        self.containerView.addSubview(transButton)
        self.transButton.addTarget(self, action: #selector(clickTransButton(_:)), for: .touchUpInside) // action methd 추가
    }
    
    override func viewDidLayoutSubviews() {
        // 하위 뷰들의 제약 조건
        self.containerView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.ocrIV.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.imageViewHeight)
        }
        self.transButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(self.ocrIV.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    init(image: UIImage, recLanguage: String) { // image: , recLanguage: 인식할 언어
        super.init(nibName: nil, bundle: nil)
        self.ocrIV.image = image 
        self.ocrModel = OCRModel(extractImg: image, recLanguage: recLanguage)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - action method, 수정 예정
extension TextRecognizerView {
    @objc func clickTransButton(_ sender: Any) { // 번역 버튼 클릭
        print("번역 버튼 클릭")
    }
}

// MARK: - Constants
private enum Constants {
    static let imageViewHeight: CGFloat = UIScreen.main.bounds.height * 0.75
}

