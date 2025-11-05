import Foundation
import SwiftUI
import Vision

class OCRManager {
    /// CVPixelBuffer와 OCR 범위 입력받아서 completion handler로 결과 텍스트 String 옵셔널 반환
    static func recognizeText(
        from pixelBuffer: CVPixelBuffer?,
        in areaOfInterest: CGRect,
        completion: @escaping (String?) -> Void
    ) {
        guard let pixelBuffer else {
            completion(nil)
            return
        }

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
                completion(finalRecognizedString)
            }
        }

        // 숫자 인식 최적화 설정
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.automaticallyDetectsLanguage = true
        request.regionOfInterest = areaOfInterest // 인식 영역 설정

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("OCR 수행 실패: \(error)")
            completion(nil)
        }
    }

    /// 텍스트에 어떤 노선번호가 있는지 확인하는 함수
    static func isTextContains(text: String, routeNumbers: [String]) -> [String]? {
        var numsContains: [String] = []

        for routeNo in routeNumbers {
            if text.contains(routeNo), !numsContains.contains(routeNo) {
                numsContains.append(routeNo)
            }
        }
        return numsContains.isEmpty ? nil : numsContains
    }
}
