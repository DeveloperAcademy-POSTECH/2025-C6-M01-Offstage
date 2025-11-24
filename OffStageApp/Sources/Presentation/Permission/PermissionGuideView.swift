import SwiftUI

struct PermissionGuideView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("시작하기 전에")
                    .font(Font.custom("SF Pro", size: 23).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.white))
                Text("더 나은 앱 사용을 위해\n동의가 필요한 권한을 확인해주세요.")
                    .font(Font.custom("SF Pro", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.gray50))
            }
            .padding(.top, 80)
            .padding(.bottom, 50)

            VStack(alignment: .leading, spacing: 20) {
                Text("필수 접근 권한")
                    .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                    .foregroundColor(Color(.primarynormal))

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(.gray400)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "paperplane.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("위치 정보")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Text("위치 기반 정류장 안내를 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.gray100))
                    }
                }
                .padding(.bottom, 10)

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(.gray400)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "camera.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("카메라")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.white))
                        Text("버스 번호 인식을 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.gray100))
                    }
                }
                .padding(.bottom, 10)

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(.gray400)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "mic.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("마이크")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.white))
                        Text("음성 검색 기능을 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.gray100))
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(20)
            .frame(width: 361, alignment: .topLeading)
            .background(Color(.backgroundstrong))
            .cornerRadius(16)

            Spacer()

            Text("위 권한 사용에 동의하지 않는 경우\n앱 사용이 제한됩니다.")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(Color(.gray100))
                .multilineTextAlignment(.center)
                .padding(.vertical, 25)

            Button {
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                router.root = .home
            } label: {
                Text("시작하기")
                    .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.black500))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 30)
        }
    }
}
