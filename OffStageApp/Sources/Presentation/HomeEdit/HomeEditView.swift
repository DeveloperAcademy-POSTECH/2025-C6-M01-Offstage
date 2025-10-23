import SwiftUI

struct HomeEditView: View {
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.black)
                .frame(height: 100)
            
            Text("추후 개발 예정입니다.")
                .font(.title3)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
            }

            ToolbarItem(placement: .principal) {
                VStack {
                    Text("홈 화면 편집")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .frame(height: 400)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    // 미리보기용 Mock Router
    RouterView(router: Router<AppRoute>(root: .homeedit))
}
