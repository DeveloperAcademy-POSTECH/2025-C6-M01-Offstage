import SwiftUI

/// 비전버스 화면에서 실시간 버스정보를 가져올 때 활용하는 상단 도착정보용 서브뷰
struct WaitingBusRealtimeInfoView: View {
    let routeno: String
    let arrivalSecconds: Int

    var arrialTimeText: String {
        BusArrivalFormatter.formatArrivalTime(arrivalSecconds)
    }

    var body: some View {
        VStack(alignment: .leading) {
            RouteNumberToken(routeno: routeno)

            (
                Text(arrialTimeText)
                    .foregroundColor(Color(.primarynormal))
                    .fontWeight(.bold)

                    +

                    Text(" 도착 예정")
            )
            .font(.title3)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel("\(routeno) 버스 \(arrialTimeText) 도착 예정")
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color(red: 0.08, green: 0.08, blue: 0.11))
        )
    }
}

#Preview {
    WaitingBusRealtimeInfoView(routeno: "207", arrivalSecconds: 200)
}
