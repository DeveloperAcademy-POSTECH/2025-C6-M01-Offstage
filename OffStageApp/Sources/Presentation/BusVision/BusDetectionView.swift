//
//  BusDetectionView.swift
//  OffStageApp
//
//  Created by 석민솔 on 10/21/25.
//
import SwiftUI

/// BusDetectionViewController를 SwiftUI에서 쓸 수 있도록 처리
struct BusDetectionView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> BusDetectionViewController {
        BusDetectionViewController()
    }

    func updateUIViewController(_: BusDetectionViewController, context _: Context) {}
}
