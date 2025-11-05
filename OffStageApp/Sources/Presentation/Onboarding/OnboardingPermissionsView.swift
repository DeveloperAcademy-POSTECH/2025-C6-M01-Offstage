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
                        HStack {
                            Image(systemName: "chevron.left")
                                .accessibilityHidden(true)
                            Text(L10n.Common.Ui.buttonPrevious)
                        }
                        .font(Font.custom("SF Pro", size: 17)
                            .weight(.semibold)
                        )
                        .padding(.leading)
                        .foregroundColor(Color(red: 0.77, green: 0.78, blue: 0.83))
                    }
                    Spacer()
                }
                Text(L10n.Onboarding.Ui.titlePermissions)
                    .font(Font.custom("SF Pro", size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.77, green: 0.78, blue: 0.83))
            }

            VStack(spacing: 10) {
                Text(L10n.Onboarding.Ui.headerPermissions)
                    .font(Font.custom("SF Pro", size: 23).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.89, green: 0.91, blue: 0.94))

                Text(L10n.Onboarding.Ui.subtitlePermissions)
                    .font(Font.custom("SF Pro", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 50)

            VStack(alignment: .leading, spacing: 30) {
                Text(L10n.Onboarding.Ui.titleRequiredAccess)
                    .font(Font.custom("SF Pro", size: 20).weight(.semibold))
                    .foregroundColor(Color(.primarynormal))

                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.20)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "paperplane.fill")
                            .accessibilityHidden(true)
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.Onboarding.Ui.labelLocation)
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(L10n.Onboarding.Ui.descriptionLocation)
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
                            .accessibilityHidden(true)
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.Onboarding.Ui.labelCamera)
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(L10n.Onboarding.Ui.descriptionCamera)
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
                            .accessibilityHidden(true)
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.Onboarding.Ui.labelMicrophone)
                            .font(Font.custom("SF Pro", size: 17).weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(L10n.Onboarding.Ui.descriptionMicrophone)
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

            Text(L10n.Onboarding.Ui.labelDisclaimer)
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(Color(red: 0.7, green: 0.71, blue: 0.73))
                .padding(.vertical, 25)

            Button {
                onFinish()
            } label: {
                Text(L10n.Onboarding.Ui.buttonStartApp)
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
}
