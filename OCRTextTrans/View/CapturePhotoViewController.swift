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
    // MARK: - view object
    private lazy var captureIV: UIImageView = { // 찍은 사진을 보여주는 이미지 뷰
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var topContainerView: UIView = { // 상단 뷰
        let view = UIView()
        view.backgroundColor = Constants.containerColor
        return view
    }()
    
    private lazy var recognizeLanguageButton: UIButton = { // 이미지에서 텍스트를 인식할 언어를 선택하는 버튼
        let button = UIButton()
        button.setTitle(Constants.languageButtonTitle, for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        // 버튼의 라벨과 이미지의 위치 지정
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()
    private lazy var bottomContainerView: UIView = { // 하단 뷰
        let view = UIView()
        view.backgroundColor = Constants.containerColor
        return view
    }()
    
    private lazy var bottomStackView: UIStackView = { // 하단 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = Constants.containerColor
        return stackView
    }()
    private lazy var cropBtn: UIButton = { // 자르기 버튼
        let button = UIButton()
        button.setTitle("자르기", for: .normal)
        return button
    }()
    private lazy var reCaptureBtn: UIButton = { // 다시 찍기 버튼
        let button = UIButton()
        button.setTitle("다시 선택", for: .normal)
        return button
    }()
    private lazy var ocrBtn: UIButton = { // 번역 버튼
        let button = UIButton()
        button.setTitle("텍스트 탐지", for: .normal)
        return button
    }()
    
    init(image: UIImage) { // 생성자: 이전 화면에서 찍은 사진을 받음
        super.init(nibName: nil, bundle: nil)
        self.captureIV.image = image
        
        let fixedImage = image.fixOrientation()
        self.captureIV.image = fixedImage
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = Constants.barTintColor // 네비게이션 바 색상 
        
        self.view.addSubview(captureIV)
        self.view.addSubview(topContainerView)
        self.view.addSubview(bottomContainerView)
        // topContainer
        self.topContainerView.addSubview(recognizeLanguageButton)
        // bottomContainer
        self.bottomStackView.addArrangedSubview(cropBtn)
        self.bottomStackView.addArrangedSubview(reCaptureBtn)
        self.bottomStackView.addArrangedSubview(ocrBtn)
        self.bottomContainerView.addSubview(bottomStackView)
        self.navigationItem.title = Constants.screenTitle
        // attach action method
        self.recognizeLanguageButton.addTarget(self, action: #selector(topBtnclick(_:)), for: .touchUpInside)
        self.reCaptureBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
        self.cropBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
        self.ocrBtn.addTarget(self, action: #selector(bottomBtnClick(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        // MARK: - 제약 조건
        super.viewDidLayoutSubviews()
        topContainerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(ScreenInfo.screenHeight/15)
            make.bottom.equalTo(self.captureIV.snp.top)
        }
        recognizeLanguageButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.leading.trailing.top.equalTo(self.view.safeAreaLayoutGuide)
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
            make.height.equalTo(ScreenInfo.screenHeight/11)
        }
    }
    private func createLanguageAlert() { // 인식 언어를 선택하지 않은 경우 언어 선택 alert생성
        let alert = UIAlertController(title: nil, message: Constants.selectLanguageMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - action method
extension CapturePhotoViewController {
    // 화면 상단의 액션 메소드
    @objc func topBtnclick(_ sender: UIButton) { // 피커뷰 위치 선택한 위치로 옮기기
        let languageVC = LanguagePickerViewController() // 언어선택 피커뷰 생성
        languageVC.preferredContentSize = CGSize(width: ScreenInfo.screenWidth, height: ScreenInfo.screenHeight/3)
        
        let alert = UIAlertController(title: "언어 선택", message: "", preferredStyle: .actionSheet) // 피커뷰를 담을 alert 컨트롤러 생성
        alert.setValue(languageVC, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "선택", style: .default) { (_) in // ok button
            DispatchQueue.main.async {
                self.recognizeLanguageButton.setTitle(languageVC.currentLanguage, for: .normal)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { (_) in }) // cancel button
        self.present(alert, animated: true) // 언어 선택 피커뷰 뷰컨트롤러 전환
    }
    // 하단 버튼의 액션 메소드
    @objc func bottomBtnClick(_ sender: UIButton) {
        switch sender {
        case cropBtn: // 자르기 버튼
            let cropviewController = CropViewController(image: self.captureIV.image!)
            cropviewController.delegate = self // delegate 위임
            present(cropviewController, animated: true)
        case reCaptureBtn: // 다시 찍기 버튼
            self.navigationController?.popViewController(animated: true)
        case ocrBtn: // 번역 버튼: 이미지와 텍스트를 인식할 언어를 전달
            guard self.recognizeLanguageButton.title(for: .normal) != Constants.languageButtonTitle else { // 언어를 선택하지 않은 상태
                self.createLanguageAlert() // alert 생성
                return
            }
            let textRecognizerVC = TextRecognizerView(image: self.captureIV.image!, recLanguage: self.recognizeLanguageButton.title(for: .normal)!)
            self.navigationController?.pushViewController(textRecognizerVC, animated: false)
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
    // crop이 완료된 경우
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.captureIV.image = image // crop된 이미지를 현재 이미지로 변경
        self.dismiss(animated: true)
    }
    // crop이 취소된 경우
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        self.dismiss(animated: false)
    }
}

// MARK: - Constants
private enum Constants {
    static let screenTitle: String = "사진"
    static let languageButtonTitle: String = "언어 선택"
    static let selectLanguageMsg: String = "인식할 언어를 선택해 주세요."
    static let userDefaultsKey: String = "recLanguage" // 인식할 언어를 선택하는 버튼의 타이틀을 가져오는 키
    static let containerColor: UIColor = .lightGray
    static let barTintColor: UIColor = .white
}
