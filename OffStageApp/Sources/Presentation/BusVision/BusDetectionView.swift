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
    @Binding var detectedRouteNumbers: [String]

    func makeUIViewController(context _: Context) -> BusDetectionViewController {
        let vc = BusDetectionViewController()
        vc.routeNumbersToDetect = routeNumbersToDetect
        vc.onDetectedRouteNumbersChanged = { detected in
            detectedRouteNumbers = detected
        }
        return vc
    }

    func updateUIViewController(_: BusDetectionViewController, context _: Context) {}
}
