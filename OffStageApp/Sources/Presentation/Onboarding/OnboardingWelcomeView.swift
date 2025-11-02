import SwiftUI

struct OnboardingWelcomeView: View {
    var onStart: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text("저시력 시각장애인을 위한\n버스 안내 앱입니다.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()

            Text("탑승할 버스 번호판을 구별하여\n저시력자가 스스로 버스를 탈 수\n있게 돕습니다.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            Spacer()

            Button("시작하기") {
                onStart()
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding()
        }
    }
}
