import SwiftUI
import Vision

// MARK: 이미지 정제
extension BusDetectionViewController {
    /// 프레임이미지 버스에 맞게 자르기
    func cropImage(
        pixelBuffer: CVPixelBuffer?,
        prediction: VNRecognizedObjectObservation
    ) -> CGImage? {
        guard let pixelBuffer else { return nil }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()

        let imageSize = CGSize(
            width: CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
            height: CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        )

        var boundingBox = convertToAbsoluteCoordinates(
            imageSize: imageSize,
            boundingBox: prediction.boundingBox
        )

        // 버스 앞면인 경우 번호판 제거
        if prediction.labels.first?.identifier == "bus_front" {
            boundingBox = cropFrontBusBottom(boundingBox: boundingBox)
        }

        // 마진 추가하여 최종 자르기틀 생성
        let rectToCrop = addMargins(
            imageSize: imageSize,
            boundingBox: boundingBox
        )

        let croppedCIImage = ciImage.cropped(to: rectToCrop)

        guard let cgImage = context.createCGImage(
            croppedCIImage,
            from: croppedCIImage.extent
        )
        else { return nil }

        return cgImage
    }

    /// 이미지 크기 표준화
    func resizeImage(_ cgimage: CGImage, targetSize: CGSize = .init(width: 500, height: 500)) -> CGImage? {
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

    /// 이미지에서 바운딩박스 영역을 나타내는 CGRect 구하기
    func convertToAbsoluteCoordinates(imageSize: CGSize, boundingBox: CGRect) -> CGRect {
        CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )
    }

    /// 버스번호판 자르기용 하단부 자르기
    /// - 상단부의 80%만 남기고 하단부 20% 날리기
    func cropFrontBusBottom(boundingBox: CGRect) -> CGRect {
        CGRect(
            x: boundingBox.origin.x,
            y: boundingBox.origin.y,
            width: boundingBox.width,
            height: boundingBox.height * 0.8
        )
    }

    /// ocr 이미지를 위한 영역조절: 인식된 범위보다 조금씩 여유 가지고 자르도록 하기
    func addMargins(imageSize: CGSize, boundingBox: CGRect) -> CGRect {
        // 이미지 크기의 5% 계산
        let marginPercent: CGFloat = 0.05
        let horizontalMargin = imageSize.width * marginPercent
        let verticalMargin = imageSize.height * marginPercent

        // 좌측, 우측 horizontalMargin 추가
        let newX = max(0, boundingBox.origin.x - horizontalMargin)
        let newWidth = min(imageSize.width - newX, boundingBox.width + horizontalMargin * 2)

        // 상단에만 verticalMargin 추가 (하단은 그대로)
        let newY = max(0, boundingBox.origin.y - verticalMargin)
        let newHeight = min(imageSize.height - newY, boundingBox.height + verticalMargin)

        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}
