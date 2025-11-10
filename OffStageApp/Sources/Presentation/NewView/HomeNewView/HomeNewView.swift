import SwiftUI

struct HomeNewView: View {
    @EnvironmentObject var router: NewRouter<NewAppRoute>
    @State private var showSheet = false

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
            ZStack {
                Text("버스온다")
                    .font(.body)
                    .padding()
                HStack {
                    Spacer()
                    Image(systemName: "gearshape")
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .padding()
                }
            }

            Spacer()

            VStack {
                Text("몇번 버스를\n탑승하시나요?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom, 100)

                Button {
                    showSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color(.primarynormal), lineWidth: 8)
                            .frame(width: 110, height: 110)
                        Image(systemName: "microphone")
                            .font(.system(size: 45))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 80)
            }

            Spacer()
        }
        .sheet(isPresented: $showSheet) {
            VoiceFlowSheet()
        }
    }
}
