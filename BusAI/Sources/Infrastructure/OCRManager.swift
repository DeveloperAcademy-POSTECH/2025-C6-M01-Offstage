import Foundation
import SwiftUI
import Vision

class OCRManager {
    /// CGImage입력받아서 completion handler로 결과 텍스트 String 옵셔널 반환
    static func recognizeText(from image: CGImage, completion: @escaping (String?) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            if let error {
                print("OCR 에러: \(error)")
                completion(nil)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let finalRecognizedString = recognizedStrings.joined(separator: "\n")

            if finalRecognizedString.isEmpty {
                completion(nil)
            } else {
                print(finalRecognizedString)
                completion(finalRecognizedString)
            }
        }

        // 숫자 인식 최적화 설정
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false // 언어 자동 교정 끄기
        request.automaticallyDetectsLanguage = true

        let handler = VNImageRequestHandler(cgImage: image)

        do {
            try handler.perform([request])
        } catch {
            print("OCR 수행 실패: \(error)")
            completion(nil)
        }
    }
}
