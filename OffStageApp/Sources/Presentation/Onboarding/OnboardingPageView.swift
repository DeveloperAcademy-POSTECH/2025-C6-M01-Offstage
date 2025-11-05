import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let previousButtonTapped: () -> Void
    let nextButtonTapped: () -> Void

    var body: some View {
        VStack {
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
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }

                Spacer()

                Button {
                    nextButtonTapped()
                } label: {
                    HStack {
                        Text(L10n.Common.Ui.buttonNext)
                        Image(systemName: "chevron.right")
                            .accessibilityHidden(true)
                    }
                    .font(Font.custom("SF Pro", size: 17)
                        .weight(.semibold)
                    )
                    .padding(.horizontal)
                    .foregroundColor(.white)
                }
            }

            page.title
                .font(Font.custom("SF Pro", size: 28)
                    .weight(.bold)
                )
                .multilineTextAlignment(.center)
                .padding(.vertical, 40)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
        }
    }
}
