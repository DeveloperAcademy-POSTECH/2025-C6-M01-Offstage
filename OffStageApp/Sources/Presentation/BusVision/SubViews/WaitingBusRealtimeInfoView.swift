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

            if arrivalSecconds >= 0 {
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

            } else {
                Text("도착 정보 없음")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(red: 0.86, green: 0.87, blue: 0.91))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.black)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(arrivalSecconds >= 0 ? "\(routeno) 버스 \(arrialTimeText) 도착 예정" : "도착 정보 없음")
    }
}

#Preview {
    WaitingBusRealtimeInfoView(routeno: "207", arrivalSecconds: 200)
}
