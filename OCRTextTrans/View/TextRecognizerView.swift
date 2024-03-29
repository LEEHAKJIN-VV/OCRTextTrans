//
//  TextRecognizerView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/23.
//

import Foundation
import UIKit
import SnapKit
import Combine
import SwiftUI

// MARK: - 이미지에서 텍스트를 인식한 후 이를 보여주는 뷰 컨트롤러
class TextRecognizerView: UIViewController {
    private var ocrModel: TextRecognizerViewModel? // 이미지에서 텍스트를 추출하는 모델
    private var originalImage: UIImage // 기록 저장을 위한 오리지널 이미지
    private var recognizeLanguage: String // 이미지에서 텍스트를 인식할 언어
    
    private var recgonizeText: String = "" // 이미지에서 인식한 텍스트 -> 바인딩
    private var boxLayer: [CAShapeLayer] = [] // 이미지의 텍스트 박스의 layer -> 바인딩
    var disposalbleBag = Set<AnyCancellable>()
    
    // MARK: - uiview object
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
        button.backgroundColor = Constants.buttonColor
        return button
    }()
    
    init(image: UIImage, recLanguage: String) { // image: 텍스트를 추출하기전 원본 이미지, recLanguage: 인식할 언어
        // swift 2단계 초기화에 의해 서브 클래스의 프로퍼티 먼저 초기화 후, 슈퍼클래스의 init 호출
        self.originalImage = image
        self.recognizeLanguage = recLanguage
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.screenTitle
        
        self.view.addSubview(containerView)
        self.containerView.addSubview(ocrIV)
        self.containerView.addSubview(transButton)
        self.transButton.addTarget(self, action: #selector(clickTransButton(_:)), for: .touchUpInside) // action methd 추가
        self.ocrIV.image = self.originalImage
        self.setConstraints() // 제약 조건 설정
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !self.ocrIV.frame.isEmpty else { // 이미지 뷰의 프레임을 얻기 위해 이미지뷰의 frame이 결정된 경우 view model 생성
            return
        }
        self.ocrModel = TextRecognizerViewModel(extractImg: self.originalImage, recLanguage: self.recognizeLanguage, viewFrame: self.ocrIV.frame) //지금현재 frame이 0임
        self.setbinding()
        self.setTextBoxBinding()
    }
    private func setConstraints() { // 제약 조건 설정
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
}
// MARK: - combine
extension TextRecognizerView {
    private func setbinding() { // 이미지에서 추출한 텍스트 binding 연결
        self.ocrModel?.$recognizeText.sink { (updateText: String) in
            self.recgonizeText = updateText // update
        }.store(in: &disposalbleBag)
    }
    
    private func setTextBoxBinding() { // 이미지의 box layer binding
        self.ocrModel?.$boxLayer.sink { (boxLayer: [CAShapeLayer]) in
            self.boxLayer = boxLayer
            DispatchQueue.main.async { // main thread에서 작업
                self.boxLayer.forEach { (layer) in
                    self.ocrIV.layer.addSublayer(layer)
                }
            }
        }.store(in: &disposalbleBag)
    }
}

// MARK: - action method
extension TextRecognizerView {
    @objc func clickTransButton(_ sender: Any) { // 번역 버튼 클릭 -> 화면 전환
        let capturetransVC = CaptureImageTransView(
            image: self.originalImage, recLanguage: self.recognizeLanguage, detectText: self.recgonizeText
        )
        self.navigationController?.pushViewController(capturetransVC, animated: true) // 화면 전환
    }
}

// MARK: - Constants
private enum Constants {
    static let imageViewHeight: CGFloat = ScreenInfo.screenHeight * 0.75
    static let buttonColor: UIColor = .lightGray
    static let screenTitle: String = "텍스트 인식"
}

