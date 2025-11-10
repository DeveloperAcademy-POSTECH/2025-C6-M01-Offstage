import SwiftUI

struct HomeLegacyView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @State private var showVoiceResultSheet = false
    @State private var sheetType: SheetType?

    enum SheetType: Identifiable {
        case voiceRecognition
        case voiceResult

        var id: Int {
            switch self {
            case .voiceRecognition: 0
            case .voiceResult: 1
            }
        }
    }

    var body: some View {
        VStack {
            Text("HomeView 입니다.")

            Button {
                sheetType = .voiceRecognition
            } label: {
                Text("음성인식하기")
            }
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .voiceRecognition:
                VoiceRecognitionLegacySheet(
                    onComplete: {
                        sheetType = .voiceResult // Sheet 교체
                    }
                )
            case .voiceResult:
                VoiceResultConfirmLegacySheet()
            }
        }
    }
}

#Preview {
    HomeLegacyView()
}
