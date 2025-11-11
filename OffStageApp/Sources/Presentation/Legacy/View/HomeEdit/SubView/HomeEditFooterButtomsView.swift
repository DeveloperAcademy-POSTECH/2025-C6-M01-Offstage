import SwiftUI

struct HomeEditFooterButtomsView: View {
    let isSaveBtnDisabled: Bool
    let cancelChanges: () -> Void
    let saveChanges: () -> Void

    // todo - 아래 색상 primary 등록하면 바꾸기
    let sematicPrimaryNormal = Color(Color(.primarynormal))

    var body: some View {
        HStack(spacing: 10) {
            Button(action: cancelChanges) {
                Text(L10n.Common.Ui.buttonCancel)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 2)
                    }
            }

            Button(action: saveChanges) {
                Text(L10n.Common.Ui.buttonSave)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isSaveBtnDisabled
                            ? Color.white
                            : .black
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(
                                isSaveBtnDisabled
                                    ? Color.gray
                                    : sematicPrimaryNormal
                            )
                    }
            }
            .disabled(isSaveBtnDisabled)
        }
    }
}

#Preview {
    HomeEditFooterButtomsView(
        isSaveBtnDisabled: false,
        cancelChanges: {},
        saveChanges: {}
    )
}
