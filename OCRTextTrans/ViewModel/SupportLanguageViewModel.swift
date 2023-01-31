//
//  SupportLanguageViewModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/19.
//

import Foundation
import Combine

// MARK: - 이미지의 문자를 인식하는 언어, 번역가능한 언어를 담은 리스트
class SupportLanguageViewModel: ObservableObject {
    private var languagemodel: LanguageModel = LanguageModel()
    @Published var languageList: [String] = [] // 언어 목록을 가지는 Publisher
    
    init() {
        self.languageList = languagemodel.getLanguageList() // 언어 모델에서 언어 목록을 가져옴
    }
}
