import UIKit
import Vision

/// 버스인식만 된 경우에 임시로 띄워줄 흰색 테두리박스
final class TempStokeBoxesView: UIView {
    func drawBox(with predictions: [VNRecognizedObjectObservation]) {
        layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        for prediction in predictions {
            drawBox(with: prediction)
        }
    }

    private func drawBox(with prediction: VNRecognizedObjectObservation) {
        let scale = CGAffineTransform.identity.scaledBy(x: bounds.width, y: bounds.height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)

        let rectangle = prediction.boundingBox.applying(transform).applying(scale)

        let newlayer = CALayer()
        newlayer.frame = rectangle

        newlayer.backgroundColor = UIColor.clear.cgColor
        newlayer.borderColor = UIColor.white.cgColor
        newlayer.borderWidth = 1

        newlayer.cornerRadius = 0

        layer.addSublayer(newlayer)
    }
}

#Preview {
    TempStokeBoxesView()
}
