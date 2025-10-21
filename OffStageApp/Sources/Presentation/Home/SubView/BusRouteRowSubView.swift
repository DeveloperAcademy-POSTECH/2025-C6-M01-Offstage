import BusAPI
import SwiftUI

struct BusRouteRowSubView: View {
    let sampleItem: BusSampleData

    var body: some View {
        VStack {
            HStack {
                // 버스 번호 표시
                Text("\(Image(systemName: "bus.fill")) \(sampleItem.routeNumber)")
                    .font(.title3)
                Spacer()
            }
            HStack {
                // 방면 표시(종점)
                Text("\(sampleItem.endnodenm)") // 방면 표시(종점)
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack {
                // 1번째 도착버스 도착시간표시(초단위로 받을 시 분으로 표시)
                Text("\(sampleItem.arrivalMinutes1 / 60)분")
                    .foregroundColor(.green)
                // 1번째 도착버스 몇정거장 전인지 표시
                Text("\(sampleItem.stopsAway1)번째전")
                    .foregroundColor(.gray)
                // 2번째 도착버스 도착시간표시(초단위로 받을 시 분으로 표시)
                Text("\(sampleItem.arrivalMinutes2 / 60)분")
                    .foregroundColor(.green)
                // 2번째 도착버스 몇정거장 전인지 표시
                Text("\(sampleItem.stopsAway2)번째전")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

#Preview {
    BusRouteRowSubView(sampleItem: busSampleData[0])
}
