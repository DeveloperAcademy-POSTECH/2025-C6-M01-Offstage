import SwiftUI

/// 비전 결과 보여주는 뷰: 로딩 또는 탐지된 노선번호
struct AccurateBusVisionOutputView: View {
    let detectedRouteNumbers: [String]

    var body: some View {
        VStack {
            if detectedRouteNumbers.isEmpty {
                ProgressView()
            } else {
                Text(detectedRouteNumbers.joined(separator: "& "))
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

#Preview {
    AccurateBusVisionOutputView(detectedRouteNumbers: [])
}
