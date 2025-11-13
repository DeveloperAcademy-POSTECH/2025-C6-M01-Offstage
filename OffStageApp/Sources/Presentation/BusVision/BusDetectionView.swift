//
//  BusDetectionView.swift
//  OffStageApp
//
//  Created by 석민솔 on 10/21/25.
//
import SwiftUI

/// BusDetectionViewController를 SwiftUI에서 쓸 수 있도록 처리
struct BusDetectionView: UIViewControllerRepresentable {
    let routeNumbersToDetect: [String]
    @Binding var detectStatus: BusDetectStatus

    func makeUIViewController(context _: Context) -> BusDetectionViewController {
        let vc = BusDetectionViewController()
        vc.routeNumbersToDetect = routeNumbersToDetect
        vc.onDetectedStatusChanged = { status in
            detectStatus = status
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: BusDetectionViewController, context _: Context) {
        uiViewController.routeNumbersToDetect = routeNumbersToDetect
    }
}
