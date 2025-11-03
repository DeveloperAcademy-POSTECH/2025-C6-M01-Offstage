import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let nextButtonTapped: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .padding(.horizontal)

            Button {
                nextButtonTapped()
            } label: {
                Text(page.ctaTitle)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .padding(.vertical, 28)
    }
}
