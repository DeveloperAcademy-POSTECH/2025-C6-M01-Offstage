import SwiftUI

struct BusVisionHelpSheet: View {
    @Binding var showSheet: Bool

    let helpTextList = [
        "이 화면에서는 사용자가 카메라로 비추는 전경에서 버스와 버스 번호를 인식하여 음성과  햅틱으로 안내하는 인공지능 기능이 포함되어 있습니다. 이 작업은 아직 실험적인 기능으로 실제 버스 정류장 환경에서 사용 시 주의가 필요합니다.",
        "카메라 인식 화면 내에서 실시간으로 제공되는 버스 도착 정보를 확인하거나 보이스오버를 활용해 들을 수 있습니다.",
        "버스가 전 정류장에서 출발했을 때 인식 화면 내 알림을 통해 버스 인식을 위한 준비를 할 수 있습니다. 정류장에 진입하는 버스 번호를 확인 후에 탑승 의사를 표현할 수 있습니다.",
        "버스 번호 인식 기술은 정류장 환경의 조도, 버스 번호판의 형태, 장애물에 따라 정확한 정보를 제공하기 어려울 수 있습니다. 개선에 도움이 되도록 피드백을 남겨주세요.",
        "버스 도착 예정 정보는 국토교통부의 TAGO API를 활용해 제공하고 있습니다. 서버의 상황에 따라 해당 API에서 제공하고 있는 정보와 실제 정류장에서의 버스 도착시간이 정확히 일치하지 않을 수 있습니다.",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(helpTextList, id: \.self) { text in
                        Text(text)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 24)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("버스 인식 기능")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .accessibilityLabel("버스 인식 기능 도움말")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                .white,
                                Color(red: 0.11, green: 0.12, blue: 0.15)
                            )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
    }
}

#Preview {
    BusVisionHelpSheet(showSheet: .constant(true))
}
