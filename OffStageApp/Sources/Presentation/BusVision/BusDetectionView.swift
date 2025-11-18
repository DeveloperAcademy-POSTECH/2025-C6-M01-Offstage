//
//  BusDetectionView.swift
//  OffStageApp
//
//  Created by 석민솔 on 10/21/25.
//
import SwiftUI

/// BusDetectionViewController를 SwiftUI에서 쓸 수 있도록 처리
struct BusDetectionView: UIViewControllerRepresentable {
    let routeNumberToDetect: String
    @Binding var detectStatus: BusDetectStatus

    func makeUIViewController(context: Context) -> BusDetectionViewController {
        let vc = BusDetectionViewController()
        vc.routeNumberToDetect = routeNumberToDetect

        vc.onDetectedStatusChanged = { [weak coordinator = context.coordinator] status in
            DispatchQueue.main.async {
                coordinator?.updateStatus(status)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: BusDetectionViewController, context _: Context) {
        uiViewController.routeNumberToDetect = routeNumberToDetect
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(detectStatus: $detectStatus)
    }

    class Coordinator: NSObject {
        @Binding var detectStatus: BusDetectStatus

        init(detectStatus: Binding<BusDetectStatus>) {
            _detectStatus = detectStatus
        }

        func updateStatus(_ status: BusDetectStatus) {
            detectStatus = status
        }
    }
}
