//
//  OCRModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/19.
//

import Foundation
import UIKit
import MLKit
import Combine

// MARK: - 이미지에서 텍스트를 인식하는 모델 -> 번역이 아닌 텍스트만 인식함
class TextRecognizerViewModel {
    private var ocrImage: UIImage // 텍스트를 추출할 이미지
    private var recognitionLanguage: String? // 이미지에서 인식할 글자
    private var languagetype: LanguageType // 언어의 region type
    
    @Published var recognizeText: String = "" // 이미지에서 인식한 텍스트
    @Published var boxLayer: [CAShapeLayer] = [] // 이미지의 box layer
    var disposalbleBag = Set<AnyCancellable>()
    private var viewFrame: CGRect // 이미지 뷰의 frame
 
    init(extractImg: UIImage, recLanguage: String, viewFrame: CGRect) { // 생성자 viewFrame: box layer를 그리기 위해 필요
        self.viewFrame = viewFrame
        self.ocrImage = extractImg
        self.languagetype = LanguageModel.getLanguageRegion(language: recLanguage)
        self.startOCR()
    }
    func startOCR() { // Start OCR
        switch self.languagetype { // 언어의 region에 따른 텍스트 인식기 생성
        case .latin:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: TextRecognizerOptions()))
        case .devanagari:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: DevanagariTextRecognizerOptions()))
        case .japanese:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: JapaneseTextRecognizerOptions()))
        case .chinese:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: ChineseTextRecognizerOptions()))
        case .korean:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: KoreanTextRecognizerOptions()))
        }
    }
    private func recoginzeText(textRecognizer: TextRecognizer) { // 이미지내 텍스트 인식
        let inputImage = VisionImage(image: self.ocrImage)
        inputImage.orientation = self.ocrImage.imageOrientation // 이미지 방향 설정

        textRecognizer.process(inputImage) { result, error in
            guard error == nil, let resultText = result else {  // error -> return
                return
            }
            self.recognizeText = resultText.text // text binding
            var tmpLayer: [CAShapeLayer] = [] // box layer
            
            for block in resultText.blocks {
                for line in block.lines { // text line 인식
                    let realframe = self.changeScaleFrame(boxFrame: line.frame) // line frame scale fit
                    let shapeLayer = self.createShapeLayer(frame: realframe)
                    tmpLayer.append(shapeLayer)
                }
            }
            self.boxLayer = tmpLayer // box layer binding
        }
    }
    /// 1. 이미지 뷰의 content mode가 scaledAspectFit 모드 이면 비율을 유지하면서 뷰의 사이즈에 맞게 이미지를 늘린다.
    /// 2. 그러므로 실제 이미지의 사이즈를 얻으려면 ratio만큼 이미지에 곱해줘야한다.
    /// 3. 텍스트 인식으로 얻은 line.frame 값도 실제 이미지 위치가 아닌 scaledAspectFit에 의해서 얻어진 frame이므로 ratio를 곱한다
    /// 4. 이미지와 인식된 box frame모두에게 ratio를 곱하면 실제 이미지의 text rectangle을 얻을 수 있다.
    private func changeScaleFrame(boxFrame: CGRect) -> CGRect { // 인식된 박스의 frame을 scale 조정
        let imageViewWidth = self.viewFrame.size.width
        let imageViewHeight = self.viewFrame.size.height
        let imageWidth = self.ocrImage.size.width
        let imageHeight = self.ocrImage.size.height
        
        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale: CGFloat = (imageViewAspectRatio > imageAspectRatio) ?
        imageViewHeight / imageHeight : imageViewWidth / imageWidth
        
        let boxWidthScaled = boxFrame.width * scale
        let boxHeightScaled = boxFrame.height * scale
        
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let imagePointX = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let imagePointY = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)
        
        let boxPointX = imagePointX + boxFrame.origin.x * scale
        let boxPointY = imagePointY + boxFrame.origin.y * scale
        
        return CGRect(x: boxPointX, y: boxPointY, width: boxWidthScaled, height: boxHeightScaled)
    }

    private func createShapeLayer(frame: CGRect) -> CAShapeLayer { // Box Layer를 만드는 함수
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath
        
        shapeLayer.strokeColor = Constants.lineColor
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }
    
    // MARK: - private
    private enum Constants {
        static let lineWidth: CGFloat = 2.0
        static let lineColor = UIColor.green.cgColor
        static let fillColor = UIColor.clear.cgColor // 투명
    }
}


