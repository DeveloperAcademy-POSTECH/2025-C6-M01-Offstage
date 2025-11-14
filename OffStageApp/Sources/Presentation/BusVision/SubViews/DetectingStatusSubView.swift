import SwiftUI

/// 버스 인식 상태에 따라 지정된 UI를 보여주는 뷰
struct DetectingStatusSubView: View {
    let status: BusDetectStatus

    var body: some View {
        VStack {
            switch status {
            case .unDetected:
                Text(L10n.BusVision.Detection.inProgress)
                    .font(.title)
                    .fontWeight(.bold)

                VisionLoadingAnimationView()
                    .frame(height: 20)

            case .notMine:
                Text(L10n.BusVision.Detection.wrongBusNumber)
                    .font(.title)
                    .fontWeight(.bold)

            case let .mineDetected(routeNumber):
                Text(routeNumber)
                    .font(.system(size: 148, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(.primarynormal))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.black)
        )
    }
}

#Preview {
    ZStack {
        Color.white
        VStack {
            DetectingStatusSubView(status: .unDetected)
            DetectingStatusSubView(status: .notMine)
            DetectingStatusSubView(status: .mineDetected(routeNum: "207"))
        }
        .padding(.horizontal)
    }
}
