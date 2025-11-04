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

            VStack {
                page.title
                    .font(Font.custom("SF Pro", size: 28)
                        .weight(.bold)
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                    .padding(.top, 60)

                Spacer()

                Button {
                    nextButtonTapped()
                } label: {
                    Text(page.ctaTitle)
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
}
