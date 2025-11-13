import SwiftUI

/// 비전버스에서 곧도착 / 지나갔을 때 알람 뜨는 뷰
struct SoonArrivalAlertView: View {
    /// 진입중일 때를 나타내야하는지
    /// - true: 진입중입니다
    /// - false: 지나갔습니다
    let isArrivingAlert: Bool
    /// 보여줄 노선번호
    let routeNo: String

    var notiText: String {
        isArrivingAlert
            ? "\(routeNo)번 버스가 정류장 진입 중입니다."
            : "\(routeNo)번 버스가 정류장을 지나갔습니다."
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bell.circle")
                .font(.title2)

            Text(notiText)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.9))
        )
    }
}

#Preview {
    SoonArrivalAlertView(isArrivingAlert: true, routeNo: "207")
}
