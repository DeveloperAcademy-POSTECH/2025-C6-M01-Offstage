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
                    Text("\(Image(systemName: "chevron.left")) 이전")
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
                    Text("다음 \(Image(systemName: "chevron.right"))")
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
