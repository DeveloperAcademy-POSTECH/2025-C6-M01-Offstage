import Vision

/// OCR 결과를 담을 구조체
private struct OCRResult {
    let prediction: VNRecognizedObjectObservation
    let isMyBus: Bool
}

/// BusDetectionViewController + DetectionProcessing
extension BusDetectionViewController {
    /// AI 모델 결과 처리
    func handleVisionResults(_ request: VNRequest, error _: Error?) {
        guard let predictions = request.results as? [VNRecognizedObjectObservation]
        else {
            onDetectedStatusChanged?(.unDetected)
            return
        }

        drawingBoxesView?.drawBox(with: [])
        #if DEBUG_MODE
            tempStrokeBoxesView?.drawBox(with: [])
        #endif

        let highConfidencePredictions = predictions.filter { $0.confidence >= 0.8 }
        guard !highConfidencePredictions.isEmpty else {
            onDetectedStatusChanged?(.unDetected)
            return
        }

        performOCRAndUpdateStatus(on: highConfidencePredictions)
    }

    private func performOCRAndUpdateStatus(on predictions: [VNRecognizedObjectObservation]) {
        let ocrGroup = DispatchGroup()
        let ocrResultQueue = DispatchQueue(label: "com.busvision.ocrResults")
        var ocrResults: [OCRResult] = []

        for prediction in predictions {
            // 이미지 영역 정하기
            guard let areaOfInterest = cropBusArea(prediction: prediction) else {
                print("이미지 자르기 실패")
                continue
            }

            ocrGroup.enter()

            // 자른 이미지 OCR 처리하기
            OCRManager.recognizeText(
                from: currentPixelBuffer,
                in: areaOfInterest
            ) { ocrText in
                defer {
                    ocrGroup.leave()
                }

                guard let ocrText else {
                    print("OCR 처리 실패")
                    return
                }
                print("--BUS OCR--\n\(ocrText)\n------")

                let isMyBus = OCRManager.isTextContains(
                    text: ocrText,
                    routeNumber: self.routeNumberToDetect
                )

                ocrResultQueue.sync {
                    ocrResults.append(
                        OCRResult(
                            prediction: prediction,
                            isMyBus: isMyBus
                        )
                    )
                }
            }
        }

        // 한 프레임의 prediction이 끝나면 한 번에 처리
        ocrGroup.notify(queue: .main) {
            self.updateDetectionStatus(
                with: ocrResults,
                from: predictions
            )
        }
    }

    private func updateDetectionStatus(
        with ocrResults: [OCRResult],
        from predictions: [VNRecognizedObjectObservation]
    ) {
        if let myBusResult = ocrResults.first(where: { $0.isMyBus }) {
            // 내가 탈 버스
            onDetectedStatusChanged?(
                .mineDetected(routeNum: routeNumberToDetect)
            )

            drawMyBus(with: myBusResult.prediction)

        } else if !ocrResults.isEmpty {
            // 버스는 감지됐지만 내 버스가 아님
            onDetectedStatusChanged?(.notMine)
        } else {
            // 버스가 아예 없음 || OCR 실패 (버스 감지했지만 OCR 안됨)
            onDetectedStatusChanged?(.unDetected)
        }

        #if DEBUG_MODE
            drawJustBus(with: ocrResults, from: predictions)
        #endif
    }

    /// 나의 버스인 경우 강조된 형태의 바운딩박스 그리기
    func drawMyBus(with prediction: VNRecognizedObjectObservation) {
        drawingBoxesView?.drawBox(with: [prediction])
    }
}

// MARK: 디버그모드인 경우 활용할 바운딩박스 관련 로직

#if DEBUG_MODE
    private extension BusDetectionViewController {
        /// 인지만 된 상태의 버스: 흰색 stroke 바운딩박스 그리기
        func drawJustBus(with ocrResults: [OCRResult], from predictions: [VNRecognizedObjectObservation]) {
            let myBusPredictions = ocrResults.filter(\.isMyBus).map(\.prediction)
            tempStrokeBoxesView?.drawBox(
                with: predictions.filter { prediction in
                    !myBusPredictions.contains { $0.uuid == prediction.uuid }
                }
            )
        }
    }
#endif
