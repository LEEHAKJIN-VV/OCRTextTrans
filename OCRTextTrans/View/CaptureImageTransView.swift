//
//  CaptureImageTransView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/13.
//

import Foundation
import UIKit
import SnapKit
import Combine
import NVActivityIndicatorView

// 카메로라 찍은 이미지에서 텍스트를 추출하여 번역된 결과를 보여주는 뷰 컨트롤러
class CaptureImageTransView: UIViewController {
    private var recognitionLanguage: String = "" // 인식한 언어
    private var detectText: String? // 이미지에서 추출한 언어
    private var viewModel: CaptureImageTransViewModel // view model: 번역 모델
    
    var translatedText: String = "" // 번역된 텍스트
    var disposalbleBag = Set<AnyCancellable>()
    // MARK: - view object
    private lazy var containerView: UIView = { // 번역 화면의 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var languageStackView: UIStackView = { // 언어 선택 스택 뷰
        let stackview = UIStackView()
        stackview.axis = .horizontal // 수평 스택 뷰
        stackview.distribution = .fillEqually
        return stackview
    }()
    private lazy var recognizeLanguageButton: UIButton = { // 이미지에서 인식한 텍스트 언어 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        // 버튼의 라벨과 이미지의 위치 지정
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()
    private lazy var translateLanguageButton: UIButton = { // 이미지에서 텍스트를 인식할 언어를 선택하는 버튼
        let button = UIButton()
        button.setTitle(Constants.initTransLanguage, for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .white
        // 버튼의 라벨과 이미지의 위치 지정
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
    
    private lazy var textStackView: UIStackView = { // 원본 텍스트와 번역된 텍스트, 복사 버튼을 포함하는 스택 뷰
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.distribution = .fillEqually
        return stackview
    }()
    private lazy var topContainerView: UIView = { // top container view
        let view = UIView()
        return view
    }()
    private lazy var originTextView: UITextView = { // 인식된 텍스트를 보여주는 텍스트 뷰
        let textview = UITextView()
        textview.font = UIFont.preferredFont(forTextStyle: .subheadline) // textview의 font 크기 설정
        textview.adjustsFontForContentSizeCategory = true // text의 dynamic type 설정
        textview.textColor = .black // 글자 색
        textview.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // uitextview의 text 여백 설정
        textview.backgroundColor = .gray // 배경색
        textview.isEditable = false // 편집 여부
        return textview
    }()
    private lazy var originOptionStackview: UIStackView = { // 원본 텍스트에 대한 옵션 스택 뷰
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.backgroundColor = .black
        return stackview
    }()
    private lazy var originCopyButton: UIButton = { // 원본 텍스트를 복사하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        button.tintColor = .lightGray
        button.contentVerticalAlignment = .center
        return button
    }()
    
    
    private lazy var translateButton: UIBarButtonItem = { // 번역 버튼
        let button = UIBarButtonItem(title: "번역하기", style: .plain, target: self, action: #selector(onClickTranslateButton(_:)))
        button.tintColor = .red
        return button
    }()
    
    private lazy var topEmptyView: UIView = { // top 쓰레기 뷰 -> 복사 버튼을 왼쪽에 배치하기 위해 사용
        let view = UIView()
        return view
    }()
    private lazy var bottomContainerView: UIView = { // bottom container view
        let view = UIView()
        return view
    }()
    
    private lazy var transTextView: UITextView = { // 인식된 텍스트를 보여주는 텍스트 뷰
        let textview = UITextView()
        textview.font = UIFont.preferredFont(forTextStyle: .subheadline) // textview의 font 크기 설정
        textview.adjustsFontForContentSizeCategory = true // text의 dynamic type 설정
        textview.textColor = .black // 글자 색
        textview.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // uitextview의 text 여백 설정
        textview.backgroundColor = .gray // 배경색
        textview.isEditable = false // 편집 여부
        return textview
    }()
    private lazy var transOptionStackview: UIStackView = { // 번역된 텍스트에 대한 옵션 스택 뷰
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.backgroundColor = .black
        return stackview
    }()
    private lazy var transCopyButton: UIButton = { // 번역된 텍스트를 복사하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        button.tintColor = .lightGray
        button.contentVerticalAlignment = .center
        return button
    }()
    private lazy var bottomEmptyView: UIView = { // bottom 쓰레기 뷰 -> 복사 버튼을 왼쪽에 배치하기 위해 사용
        let view = UIView()
        return view
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = { // loading indicator
        let indicator = NVActivityIndicatorView(frame: .zero)
        indicator.type = .ballSpinFadeLoader
        indicator.color = .lightGray
        return indicator
    }()
    
    init(image: UIImage, recLanguage: String, detectText: String) { // recLanguage: 탐지한 언어, detectText: 탐지된 언어
        self.viewModel = CaptureImageTransViewModel(text: detectText, sourceLan: recLanguage, targetLan: "한국어") // 기본은 한국어
        super.init(nibName: nil, bundle: nil)
        self.recognitionLanguage = recLanguage // 이미지에서 텍스트를 탐지한 언어
        self.detectText = detectText
        print("recLanguage: \(recLanguage)")
        self.setBinding() // 바인딩 연결
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recognizeLanguageButton.setTitle(self.recognitionLanguage, for: .normal) // 인식 언어 버튼의 타이틀을 뷰가 로드된 후 변경
        self.navigationItem.rightBarButtonItem = self.translateButton
        // container view의 subview 등록
        self.view.addSubview(containerView)
        self.containerView.addSubview(languageStackView)
        self.containerView.addSubview(textStackView)
        // stack view의 subview 등록
        self.languageStackView.addArrangedSubview(recognizeLanguageButton)
        self.languageStackView.addArrangedSubview(languageSwitchButton)
        self.languageStackView.addArrangedSubview(translateLanguageButton)
        // container view
        self.textStackView.addArrangedSubview(topContainerView)
        self.textStackView.addArrangedSubview(bottomContainerView)
        // orignal part
        self.topContainerView.addSubview(originTextView)
        self.topContainerView.addSubview(originOptionStackview)
        self.originOptionStackview.addArrangedSubview(originCopyButton)
        self.originOptionStackview.addArrangedSubview(topEmptyView)
        // trans part
        self.bottomContainerView.addSubview(transTextView)
        self.bottomContainerView.addSubview(transOptionStackview)
        self.transOptionStackview.addArrangedSubview(transCopyButton)
        self.transOptionStackview.addArrangedSubview(bottomEmptyView)
        // 네비게이션 설정
        self.navigationItem.title = Constants.screenTitle
        self.navigationController?.navigationBar.tintColor = .white
        // view object 변경
        self.recognizeLanguageButton.setTitle(self.recognitionLanguage, for: .normal)
        self.originTextView.text = self.detectText
        // 액션메소드 등록
        self.recognizeLanguageButton.addTarget(self, action: #selector(clickLanBtn(_:)), for: .touchUpInside)
        self.languageSwitchButton.addTarget(self, action: #selector(clickLanBtn(_:)), for: .touchUpInside)
        self.translateLanguageButton.addTarget(self, action: #selector(clickLanBtn(_:)), for: .touchUpInside)
        self.originCopyButton.addTarget(self, action: #selector(clickCopyBtn(_:)), for: .touchUpInside)
        self.transCopyButton.addTarget(self, action: #selector(clickCopyBtn(_:)), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        // MARK: - 제약 조건
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        languageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        textStackView.snp.makeConstraints { make in
            make.top.equalTo(self.languageStackView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(Constants.textStackViewHeight)
        }
        topContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomContainerView.snp.top)
            make.height.equalTo(Constants.contaierViewHeight)
        }
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        originTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        originOptionStackview.snp.makeConstraints { make in
            make.top.equalTo(self.originTextView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.contaierViewHeight/7)
        }
        transTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        transOptionStackview.snp.makeConstraints { make in
            make.top.equalTo(self.transTextView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.contaierViewHeight/7)
        }
        originCopyButton.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(9)
        }
        transCopyButton.snp.makeConstraints { make in
            make.width.equalToSuperview().dividedBy(9)
        }
    }
}
// MARK: - Binding
extension CaptureImageTransView {
    private func setBinding() { // 뷰 모델과 바인딩 연결
        self.viewModel.$translatedText.sink { (updateText: String) in
            self.translatedText = updateText
            DispatchQueue.main.async {
                self.transTextView.text = self.translatedText
                self.endLoadingAnimation() // 로딩 애니메이션 종료
            }
        }.store(in: &disposalbleBag)
    }
}
// MARK: - Loading
/// 제일 처음이나 번역하기 버튼을 누르면
/// 로딩뷰를 띄우고 번역이 완료됐다는 알림이 오면 그때 로딩뷰를 없앰
/// 그냥 로딩뷰를 제일 맨위에 보여주고 완료되면 제거하면 내용이 보일듯
extension CaptureImageTransView {
    private func startLoadingAnimation() { // 애니메이션 시작
        DispatchQueue.main.async {
            self.transTextView.text = "" // 번역 텍스트 뷰 빈화면으로 만듬
        }
        self.bottomContainerView.addSubview(activityIndicator) // 하단 컨테이너 뷰의 subview로 등록
        self.activityIndicator.snp.makeConstraints { make in // 제약 조건
            make.center.equalToSuperview()
            make.width.height.equalTo(ScreenInfo.screenWidth/5)
        }
        self.activityIndicator.startAnimating() // 애니메이션 시작
    }
    private func endLoadingAnimation() { // 애니메이션 종료
        self.activityIndicator.stopAnimating()
    }
}

// MARK: - action method
extension CaptureImageTransView {
    @objc func clickLanBtn(_ sender: UIButton) { // 언어를 선택하는 버튼
        let languageVC = LanguagePickerViewController() // 언어선택 피커뷰 생성
        languageVC.preferredContentSize = CGSize(width: ScreenInfo.screenWidth, height: ScreenInfo.screenHeight/3)

        let alert = UIAlertController(title: "언어 선택", message: "", preferredStyle: .actionSheet) // 피커뷰를 담을 alert 컨트롤러 생성
        alert.setValue(languageVC, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { (_) in }) // 취소 버튼

        switch sender { // 언어 선택 버튼
        case recognizeLanguageButton:
            alert.addAction(UIAlertAction(title: "선택", style: .default) { (_) in
                self.recognizeLanguageButton.setTitle(languageVC.currentLanguage, for: .normal)
            })
            self.present(alert, animated: true) // 언어 선택 pickerview 호출
        case translateLanguageButton:
            alert.addAction(UIAlertAction(title: "선택", style: .default) { (_) in
                self.translateLanguageButton.setTitle(languageVC.currentLanguage, for: .normal)
            })
            self.present(alert, animated: true) // 언어 선택 pickerview 호출
        case languageSwitchButton:
            let tmpLanguage = self.recognizeLanguageButton.title(for: .normal)
            self.recognizeLanguageButton.setTitle(self.translateLanguageButton.title(for: .normal)!, for: .normal)
            self.translateLanguageButton.setTitle(tmpLanguage, for: .normal)
        default: // error
            fatalError()
        }
    }
      
    @objc func onClickSwitchButton(_ sender: Any) {
        let tmpLanguage = self.recognizeLanguageButton.title(for: .normal)
        self.recognizeLanguageButton.setTitle(self.translateLanguageButton.title(for: .normal)!, for: .normal)
        self.translateLanguageButton.setTitle(tmpLanguage, for: .normal)
    }
    
    @objc func onClickTranslateButton(_ sender: Any) { // 번역하기 버튼
        let soureLanguage: String = self.recognizeLanguageButton.title(for: .normal)! // 번역하기 전 언어
        let targetLanguage: String = self.translateLanguageButton.title(for: .normal)! // 번역한 후 언어
        self.startLoadingAnimation() // 로딩 애니메이션 시작
        self.viewModel.handleDownloadDeleteModel(text:self.originTextView.text, sourceLan: soureLanguage, targetLan: targetLanguage) // 번역하기 버튼 클릭 -> 뷰 바인딩을 통한
    }
    
    @objc func clickCopyBtn(_ sender: UIButton) { // 현재 텍스트를 클립보드에 저장하는 버튼
        self.showCopyToast() // toast message 출력
        switch sender { // 클립보드에 현재 텍스트뷰의 텍스트 내용 저장
        case originCopyButton:
            UIPasteboard.general.string = self.originTextView.text
        case transCopyButton:
            UIPasteboard.general.string = self.transTextView.text
        default:
            return
        }
    }
    private func showCopyToast() { // 토스트 메시지를 띄우는 함수
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.tintColor = Constants.toastTextColor
        toastLabel.text = Constants.copyMsg
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        
        self.originOptionStackview.addSubview(toastLabel)
        toastLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.5, options: .curveEaseOut, animations: { // 애니메이션
            toastLabel.alpha = 0.0
        }, completion: { (completed) in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - Constants
private enum Constants {
    static let textStackViewHeight: CGFloat = ScreenInfo.screenHeight * 0.8
    static let contaierViewHeight: CGFloat = ScreenInfo.screenHeight * 0.4
    static let initTransLanguage: String = "한국어"
    static let screenTitle: String = "번역 결과"
    static let copyMsg: String = "텍스트가 복사 되었습니다."
    
    static let toastBackgroundColor: UIColor = .black
    static let toastTextColor: UIColor = .white
}
