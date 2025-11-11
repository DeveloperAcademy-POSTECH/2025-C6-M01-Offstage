import SwiftUI

struct LegacyPermissionSubView: View {
    @Environment(\.dismiss) private var dismiss
    let deniedPermissions: [PermissionType]
    let grantedPermissions: [PermissionType]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 12) {
                    Text("버스온다에 접근\n권한이 필요합니다.")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom)

                    Text("버스온다를 사용하고 정보를\n위치, 카메라 및 마이크 접근을 허용해 주세요.")
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                .padding(.bottom)

                // 거부된 권한 목록
                VStack(alignment: .leading, spacing: 16) {
                    // 1. 위치 권한
                    HStack(spacing: 12) {
                        Image(deniedPermissions.contains(.location) ? "locationfalse" : "locationtrue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("위치 정보 접근")
                                .font(.system(size: 17))
                            Text("사용자 위치 기반 정류장 안내를 위해 사용")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 16)

                    // 2. 카메라 권한
                    HStack(spacing: 12) {
                        Image(deniedPermissions.contains(.camera) ? "camerafalse" : "cameratrue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("카메라 접근")
                                .font(.system(size: 17))
                            Text("버스 번호 인식을 위해 사용")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 16)

                    // 3. 마이크 권한
                    HStack(spacing: 12) {
                        Image(deniedPermissions.contains(.microphone) ? "micfalse" : "mictrue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("마이크 접근")
                                .font(.system(size: 17))
                            Text("음성 검색 기능을 위해 사용")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal)

                Spacer()

                // 버튼들
                VStack(spacing: 12) {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("설정으로 이동")
                            .foregroundColor(.black)
                            .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.primarynormal))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LegacyPermissionSubView(
        deniedPermissions: [.location, .camera],
        grantedPermissions: [.microphone, .speech]
    )
}
