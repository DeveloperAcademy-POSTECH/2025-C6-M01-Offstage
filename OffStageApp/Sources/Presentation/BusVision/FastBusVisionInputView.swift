import SwiftUI

struct FastBusVisionInputView: View {
    @Binding var routeNumber: String
    let onSubmit: () -> Void

    var body: some View {
        Text("몇번 버스를 탑승하시나요?")
            .font(.system(size: 21, weight: .semibold))

        TextField("탑승할 버스번호", text: $routeNumber)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.2))
            }
            .onSubmit(onSubmit)
    }
}

#Preview {
    FastBusVisionInputView(routeNumber: .constant(""), onSubmit: {})
}
