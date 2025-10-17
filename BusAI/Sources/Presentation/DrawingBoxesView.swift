import UIKit
import Vision

final class DrawingBoxesView: UIView {
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

        newlayer.backgroundColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
        newlayer.cornerRadius = 0

        layer.addSublayer(newlayer)
    }
}
