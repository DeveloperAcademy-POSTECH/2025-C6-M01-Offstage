import SwiftUI

struct OnboardingPermissionsView: View {
    let previousButtonTapped: () -> Void
    let onFinish: () -> Void

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button {
                        previousButtonTapped()
                    } label: {
                        Text("\(Image(systemName: "chevron.left")) 이전")
                            .font(Font.custom("SF Pro", size: 17)
                                .weight(.semibold)
                            )
                            .padding(.leading)
                            .foregroundColor(Color(red: 0.77, green: 0.78, blue: 0.83))
                    }
                    Spacer()
                }
                Text("권한 요청")
                    .font(Font.custom("SF Pro", size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.77, green: 0.78, blue: 0.83))
            }

            VStack(spacing: 10) {
                Text("시작하기 전에")
                    .font(Font.custom("SF Pro", size: 23).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))

                Text("더 나은 앱 사용을 위해\n동의가 필요한 권한을 확인해주세요.")
                    .font(Font.custom("SF Pro", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 50)

            VStack(alignment: .leading, spacing: 30) {
                Text("필수 접근 권한")
                    .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                    .foregroundColor(Color(red: 229 / 255, green: 255 / 255, blue: 0 / 255))

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.20)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "paperplane.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("위치 정보")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text("위치 기반 정류장 안내를 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    }
                }

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.20)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "camera.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("카메라")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text("버스 번호 인식을 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    }
                }

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.20)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "mic.fill")
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("마이크")
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text("음성 검색 기능을 위해 사용")
                            .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    }
                }
            }
            .padding(20)
            .frame(width: 361, alignment: .topLeading)
            .background(Color(red: 25 / 255, green: 26 / 255, blue: 31 / 255))
            .cornerRadius(16)

            Spacer()

            Text("위 권한 사용에 동의하지 않는 경우\n앱 사용이 제한됩니다.")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(Color(red: 0.7, green: 0.71, blue: 0.73))
                .padding(.vertical, 25)

            Button {
                onFinish()
            } label: {
                Text("시작하기")
                    .foregroundColor(.black)
                    .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 229 / 255, green: 255 / 255, blue: 0 / 255))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 30)
        }
    }
}
