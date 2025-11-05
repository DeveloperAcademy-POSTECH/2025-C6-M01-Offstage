import SwiftUI
import Vision

// MARK: 이미지 정제

extension BusDetectionViewController {
    /// 프레임이미지 버스에 맞게 자르기
    func cropBusArea(prediction: VNRecognizedObjectObservation) -> CGRect? {
        var rectToCrop: CGRect = prediction.boundingBox

        // 버스 앞면인 경우 번호판 제거
        if prediction.labels.first?.identifier == "bus_front" {
            rectToCrop = cropFrontBusBottom(boundingBox: rectToCrop)
        }

        // 마진 추가하여 최종 영역 생성
        rectToCrop = addMargins(boundingBox: rectToCrop)

        return rectToCrop
    }

    /// 이미지 크기 표준화
    func resizeImage(_ cgimage: CGImage, targetSize: CGSize = .init(width: 400, height: 400)) -> CGImage? {
        let image = UIImage(cgImage: cgimage)
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // 비율을 유지하면서 targetSize 안에 맞춤
        let scaleFactor = min(widthRatio, heightRatio)

        let scaledSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }

        return scaledImage.cgImage
    }

    /// 버스번호판 자르기용 하단부 자르기
    /// - 상단부의 80%만 남기고 하단부 20% 날리기
    func cropFrontBusBottom(boundingBox: CGRect) -> CGRect {
        let croppedHeight = boundingBox.height * 0.7
        let yOffset = boundingBox.height - croppedHeight // 하단부터 날려야 하므로

        return CGRect(
            x: boundingBox.origin.x,
            y: boundingBox.origin.y + yOffset, // y를 위로 올림
            width: boundingBox.width,
            height: croppedHeight
        )
    }

    /// ocr 이미지를 위한 영역조절: 인식된 범위보다 조금씩 여유 가지고 자르도록 하기
    func addMargins(boundingBox: CGRect) -> CGRect {
        let marginPercent: CGFloat = 0.05

        // 좌측, 우측 margin 추가
        let newX = max(0, boundingBox.origin.x - marginPercent)
        let newWidth = min(1.0 - newX, boundingBox.width + marginPercent * 2)

        // 상단에만 margin 추가 (하단은 그대로)
        let newY = max(0, boundingBox.origin.y - marginPercent)
        let newHeight = min(1.0 - newY, boundingBox.height + marginPercent)

        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}
