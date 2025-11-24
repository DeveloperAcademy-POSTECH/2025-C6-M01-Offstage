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
        ZStack {
            // 새로운 기울기 가이드 뷰
            TiltGuideView(offset: tiltManager.offsetZ, tiltState: tiltManager.tiltState)

            // 기존 디버그 뷰
            originalDebugView
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("디버그 정보")
                }
                .tag(0)
        }
        .navigationTitle("기울기 디버그")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            tiltManager.disableHapticFeedback()
        }
    }

    private var originalDebugView: some View {
        VStack(spacing: 40) {
            VStack {
                Text("현재 기울기: \(tiltManager.degreeTilt, specifier: "%.3f")")

                Text("기준 기울기: \(tiltManager.properTilt, specifier: "%.3f")")
                    .foregroundColor(.secondary)

                Text("오프셋: \(tiltManager.offsetZ, specifier: "%.3f")")
                    .foregroundColor(.secondary)

                Text("햅틱 강도: \(tiltManager.hapticIntensityForCurrentTilt(), specifier: "%.3f")")
                    .foregroundColor(.purple)

                Text("버스 인식 적합: \(tiltManager.isSuitableForBusDetection ? "YES" : "NO")")
                    .foregroundColor(tiltManager.isSuitableForBusDetection ? .green : .red)
                    .fontWeight(.semibold)
            }

            // 화살표 표시 영역
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
            .frame(width: 200, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(Color(.gray200)).opacity(0.1))
            )

            // TTS 메시지 테스트
            if !tiltManager.tiltGuideMessage.isEmpty {
                Text("TTS 메시지: \(tiltManager.tiltGuideMessage)")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }

            // 햅틱 상태 표시 및 제어
            VStack(spacing: 12) {
                Text("햅틱 상태")
                    .font(.headline)
                    .foregroundColor(.white)

                if tiltManager.isSuitableForBusDetection {
                    Text("✅ 적정 기울기 - 햅틱 중지")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                } else {
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)

                        Text("주기적 햅틱 재생 중")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
                }

                // 햅틱 주기 표시
                Text("계산된 주기: \(Double(tiltManager.calculateHapticInterval()), specifier: "%.2f")초")
                    .font(.caption2)
                    .foregroundColor(Color(.gray200))
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        TiltDebugView()
    }
}
