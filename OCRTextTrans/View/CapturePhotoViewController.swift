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
    private let screenWidth = UIScreen.main.bounds.width - 20 // screen width
    private let screenHeight = UIScreen.main.bounds.height // screen height
    
    private lazy var captureIV: UIImageView = { // 찍은 사진을 보여주는 이미지 뷰
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var topContainerView: UIView = { // 상단 뷰
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    private lazy var topStackview: UIStackView = { // 상단 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .lightGray
        return stackView
    }()
    
    private lazy var recgonitionButton: UIButton = { // 이미지에서 인식할 언어
        let button = UIButton()
        button.setTitle("탐지 언어", for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        // 버튼의 라벨과 이미지의 위치 지정
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()
    private lazy var transLanguageButton: UIButton = { // 번역할 언어
        let button = UIButton()
        button.setTitle("번역될 언어", for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()
    private lazy var languageSwitchButton: UIButton = { // 인식할 언어와 번역할 언어를 교환하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.tintColor = .white // set button icon color
        return button
    }()
    
    private lazy var bottomContainerView: UIView = { // 하단 뷰
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var bottomStackView: UIStackView = { // 하단 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .lightGray
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
        super.init(nibName: nil, bundle: nil)
        self.captureIV.image = image
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // root view
        self.view.backgroundColor = .black
        self.view.addSubview(captureIV)
        self.view.addSubview(topContainerView)
        self.view.addSubview(bottomContainerView)
        // topContainer
        self.topContainerView.addSubview(topStackview)
        self.topStackview.addArrangedSubview(recgonitionButton)
        self.topStackview.addArrangedSubview(languageSwitchButton)
        self.topStackview.addArrangedSubview(transLanguageButton)
        // bottomContainer
        self.bottomStackView.addArrangedSubview(cropBtn)
        self.bottomStackView.addArrangedSubview(reCaptureBtn)
        self.bottomStackView.addArrangedSubview(transBtn)
        self.bottomContainerView.addSubview(bottomStackView)
        self.navigationItem.title = "사진"
        // attach action method
        reCaptureBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
        cropBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
        transBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 제약 조건
        topContainerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(self.screenHeight/11)
            make.bottom.equalTo(self.captureIV.snp.top)
        }
        topStackview.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        captureIV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomContainerView.snp.top)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.snp.bottom)
            make.height.equalTo(self.screenHeight/11)
        }
        
    }
    // 하단에 위치한 버튼의 액션메소드 버튼의 타이틀로 버튼을 구분
    @objc func bottomBtnClick(_ sender: UIButton) {
        guard let btnTitle = sender.title(for: .normal) else {
            return
        }
        switch btnTitle {
        case "자르기":
            let cropviewController = CropViewController(image: self.captureIV.image!)
            cropviewController.delegate = self // delegate 위임
            present(cropviewController, animated: true)
        case "다시 찍기":
            self.navigationController?.popViewController(animated: true)
        case "번역":
            let captureImageTransVC = CaptureImageTransView()
            self.navigationController?.pushViewController(captureImageTransVC, animated: true)
        default:
            fatalError()
        }
    }
}

/*
MARK: - TOCropViewController 패키지의 CropViewControllerDelegate 프로토콜 구현
 아래 두 메소드는 이미지를 crop하거나 crop을 취소한 경우 호출되는 delegate method
 */
extension CapturePhotoViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("크롭핑 됨")
        self.captureIV.image = image
        self.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        print("취소 버튼 누름")
        self.dismiss(animated: false)
    }
}

// MARK: - Swift UI preview
#if DEBUG
import SwiftUI

struct CaptureViewControllerRepresentable: UIViewControllerRepresentable {
    // update
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    @available(iOS 13.0, *)
    func makeUIViewController(context: Context) -> UIViewController {
        CapturePhotoViewController(image: UIImage(named: "ocr2.HEIC") ?? UIImage())
        
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
