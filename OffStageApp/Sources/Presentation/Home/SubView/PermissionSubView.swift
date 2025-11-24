import SwiftUI

struct PermissionSubView: View {
    @Environment(\.dismiss) private var dismiss
    let deniedPermissions: [PermissionType]
    let grantedPermissions: [PermissionType]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 12) {
                    Text(L10n.Permission.Prompt.title)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.bottom)

                    Text(L10n.Permission.Prompt.all)
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.gray200))
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
                            .accessibilityLabel(
                                Text(
                                    deniedPermissions.contains(.location)
                                        ? L10n.Permission.A11y.Status.denied
                                        : L10n.Permission.A11y.Status.granted
                                )
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Permission.Location.title)
                                .font(.system(size: 17))
                            Text(L10n.Permission.Location.reason)
                                .font(.system(size: 16))
                                .foregroundColor(Color(.gray200))
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
                            .accessibilityLabel(
                                Text(
                                    deniedPermissions.contains(.camera)
                                        ? L10n.Permission.A11y.Status.denied
                                        : L10n.Permission.A11y.Status.granted
                                )
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Permission.Camera.title)
                                .font(.system(size: 17))
                            Text(L10n.Permission.Camera.reason)
                                .font(.system(size: 16))
                                .foregroundColor(Color(.gray200))
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
                            .accessibilityLabel(
                                Text(
                                    deniedPermissions.contains(.microphone)
                                        ? L10n.Permission.A11y.Status.denied
                                        : L10n.Permission.A11y.Status.granted
                                )
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.Permission.Mic.title)
                                .font(.system(size: 17))
                            Text(L10n.Permission.Mic.reason)
                                .font(.system(size: 16))
                                .foregroundColor(Color(.gray200))
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
                        Text(L10n.Permission.Button.goToSettings)
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
    PermissionSubView(
        deniedPermissions: [.location, .camera],
        grantedPermissions: [.microphone, .speech]
    )
}
