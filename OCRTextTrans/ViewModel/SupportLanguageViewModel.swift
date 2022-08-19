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
    @Published var languageList: [String] = ["독일어","인도어","영어","일본어","중국어","한국어"] // 알파벳순으로 정렬 해야함
}
