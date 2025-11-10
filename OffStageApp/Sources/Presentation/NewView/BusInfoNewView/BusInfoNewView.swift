import SwiftUI

struct BusInfoNewView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            Text("버스에 대한 정보를 인식하는 뷰 입니다.")
            Button {
                router.push(.busvisionlegacy)
            } label: { Text("비전버스 이동") }

            Button {
                router.push(.busvisionlegacy)
            } label: {
                HStack {
                    Image(systemName: "camera")
                    Text("버스 인식하기")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color(.white))
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.primarynormal), lineWidth: 2)
                )
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
}
