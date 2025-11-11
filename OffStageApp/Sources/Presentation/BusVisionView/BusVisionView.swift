import SwiftUI

struct BusVisionView: View {
    @EnvironmentObject var router: Router<AppRouter>

    var body: some View {
        ZStack {
            Image("BusImage")
                .resizable()
                .scaledToFill()

            VStack {
                Text("버스 인식 중\n ")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(50)

                Spacer()

                Text("0411번이 정류장에 접근하고 있어요.\n!!진입!!")

                Spacer()

                Button {
                    router.popToRoot()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color(.primarynormal), lineWidth: 6)
                            .frame(width: 90, height: 90)
                        Image(systemName: "xmark")
                            .font(.system(size: 45))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}
