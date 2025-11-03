import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let nextButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            page.title
                .font(.title2.bold())
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 5)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, pageIndex == 0 ? 0 : 12) // 0번만 padding 없음

            Button {
                nextButtonTapped()
            } label: {
                Text(page.ctaTitle)
                    .foregroundColor(.black)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
