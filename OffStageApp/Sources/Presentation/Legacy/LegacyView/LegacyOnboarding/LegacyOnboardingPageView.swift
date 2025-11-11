import SwiftUI

struct LegacyOnboardingPageView: View {
    let page: LegacyOnboardingPage
    let pageIndex: Int
    let previousButtonTapped: () -> Void
    let nextButtonTapped: () -> Void

    var body: some View {
        VStack {
            page.title
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 35)
                .padding(.bottom, 25)
            Spacer()
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            HStack {
                Button {
                    previousButtonTapped()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.32, green: 0.32, blue: 0.32)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "chevron.left")
                            .accessibilityHidden(true)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button {
                    nextButtonTapped()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.primarynormal)) // 배경색
                            .frame(width: 48, height: 48)
                        Image(systemName: "chevron.right")
                            .accessibilityHidden(true)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 15)
        }
    }
}
