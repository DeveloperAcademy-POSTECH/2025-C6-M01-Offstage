import SwiftUI

struct TiltDebugView: View {
    @StateObject private var tiltDataCollector = TiltDataCollector()
    @StateObject private var tiltManager: TiltManager

    init() {
        let dataCollector = TiltDataCollector()
        _tiltDataCollector = StateObject(wrappedValue: dataCollector)
        _tiltManager = StateObject(wrappedValue: TiltManager(dataCollector: dataCollector))
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("기울기 디버그")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 20) {
                Text("현재 기울기: \(tiltManager.degreeTilt, specifier: "%.1f")°")
                    .font(.title2)

                Text("기준 기울기: \(tiltManager.properTilt, specifier: "%.1f")°")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text("오프셋: \(tiltManager.offsetZ, specifier: "%.1f")")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // 화살표 표시 영역
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                VStack {
                    switch tiltManager.tiltState {
                    case .backward:
                        Image(systemName: "arrow.up")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)

                        Text("뒤로 기울이세요")
                            .font(.headline)
                            .foregroundColor(.blue)
                    case .forward:
                        Image(systemName: "arrow.down")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.red)

                        Text("앞으로 기울이세요")
                            .font(.headline)
                            .foregroundColor(.red)
                    case .normal:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.green)

                        Text("적정 기울기")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("기울기 디버그")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        TiltDebugView()
    }
}
