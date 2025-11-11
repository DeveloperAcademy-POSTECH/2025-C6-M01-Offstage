import SwiftUI

struct BusInfoView: View {
    @EnvironmentObject var router: Router<AppRouter>
    @State private var busRecognition = true // 로직 구현시 삭제

    var body: some View {
        VStack {
            HStack {
                Label("207(기본)", systemImage: "bus.fill")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(.gray)
                    .cornerRadius(10)

                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 25)

            HStack {
                VStack(alignment: .leading) {
                    Text(busRecognition ? "7분 03초 후" : "잠시 후")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(busRecognition ? Color(.white) : Color(.primarynormal))
                        .padding(.bottom, 6)
                    Text("도착 예정")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                Button {
                    busRecognition.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.20)) // 배경색
                            .frame(width: 55, height: 55)
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding(.top, 6)
            .padding(.horizontal, 25)

            Spacer()

            Text("도착 예정 시간이 1분 미만일 때\n버스 인식을 시작할 수 있어요.")
                .font(.callout)
                .multilineTextAlignment(.center)

            Button {
                router.push(.busvision)
            } label: {
                HStack {
                    Image(systemName: "camera")
                    Text("버스 인식하기")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(busRecognition ? Color(.systemGray5) : Color(.white))
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(busRecognition ? Color(.gray) : Color(.primarynormal), lineWidth: 5)
                )
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
}
