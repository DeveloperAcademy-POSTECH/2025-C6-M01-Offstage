import SwiftUI

struct OnboardingPermissionsView: View {
    var onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("권한 허용")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("앱을 이용하기 위해\n다음 권한의 허용이 필요합니다.")
                .font(.title2)
                .padding(.bottom, 40)

            PermissionRow(title: "알림 (필수)", description: "버스 도착 알림 정보 제공")
            PermissionRow(title: "위치 정보 (필수)", description: "사용자 위치 기반 위치 정보 제공")
            PermissionRow(title: "카메라 (필수)", description: "버스 번호 인식 정보 제공")
            PermissionRow(title: "마이크 (선택)", description: "사용자 위치 기반 위치 정보 제공")

            Spacer()

            Text("탑승할 버스 번호판을 구별하여\n저시력자가 스스로 버스를 탈 수\n있게 돕습니다.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)

            Button("다음") {
                onNext()
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
}

struct PermissionRow: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 20)
    }
}
