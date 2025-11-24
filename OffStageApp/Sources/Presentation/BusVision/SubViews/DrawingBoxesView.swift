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

        // 배경 레이어 (노란색 반투명)
        let backgroundLayer = CAShapeLayer()
        let backgroundPath = UIBezierPath(roundedRect: rectangle, cornerRadius: 10.0)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = UIColor(named: "primarynormal")?.withAlphaComponent(0.2).cgColor
        backgroundLayer.strokeColor = UIColor.white.cgColor
        backgroundLayer.lineWidth = 1.0
        layer.addSublayer(backgroundLayer)

        // 뷰파인더 레이어 (노란-초록 굵은 선)
        let viewfinderLayer = CAShapeLayer()
        let cornerLength: CGFloat = 16
        let radius: CGFloat = 10
        viewfinderLayer.path = createViewfinderPath(
            in: rectangle,
            cornerLength: cornerLength,
            radius: radius
        ).cgPath
        viewfinderLayer.strokeColor = UIColor(named: "primarynormal")?.withAlphaComponent(1.0).cgColor
        viewfinderLayer.fillColor = UIColor.clear.cgColor
        viewfinderLayer.lineWidth = 4
        viewfinderLayer.lineCap = .round
        viewfinderLayer.lineJoin = .round
        layer.addSublayer(viewfinderLayer)
    }

    private func createViewfinderPath(in rect: CGRect, cornerLength: CGFloat, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()

        // 왼쪽 위 코너 (┌) - 곡선으로
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            controlPoint: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.minX + cornerLength, y: rect.minY))

        // 오른쪽 위 코너 (┐) - 곡선으로
        path.move(to: CGPoint(x: rect.maxX - cornerLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            controlPoint: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerLength))

        // 오른쪽 아래 코너 (┘) - 곡선으로
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            controlPoint: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerLength, y: rect.maxY))

        // 왼쪽 아래 코너 (└) - 곡선으로
        path.move(to: CGPoint(x: rect.minX + cornerLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            controlPoint: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerLength))

        return path
    }
}
