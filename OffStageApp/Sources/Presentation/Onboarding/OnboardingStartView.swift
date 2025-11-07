import SwiftUI

struct OnboardingStartView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let nextButtonTapped: () -> Void

    var body: some View {
        ZStack {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)

            VStack {
                page.title
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                    .padding(.top, 60)

                Spacer()

                Button {
                    nextButtonTapped()
                } label: {
                    Text(page.ctaTitle)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .semibold))
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
}
