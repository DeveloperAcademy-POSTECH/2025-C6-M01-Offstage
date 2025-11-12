import UIKit

class BusDetectStatusView: UIView {
    // MARK: - Properties

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 20
        return view
    }()

    var detectStatus: BusDetectStatus = .unDetected {
        didSet {
            updateStatus()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(label)
        updateStatus()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // containerView frame (외부 padding 16)
        containerView.frame = bounds.inset(by: UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        ))

        // label frame (내부 padding 상하 8, 좌우 16)
        label.frame = containerView.bounds.inset(by: UIEdgeInsets(
            top: 8,
            left: 16,
            bottom: 8,
            right: 16
        ))
    }

    private func updateStatus() {
        label.text = "뷰 교체 예정"
    }

    func updateStatus(to status: BusDetectStatus) {
        DispatchQueue.main.async {
            self.detectStatus = status
        }
    }
}
