import BusAPI
import SwiftUI

struct BusStopSelectionView: View {
    // MARK: - Properties

    /// 현재 선택된 정류장 (HomeView에서 전달받음)
    let currentBusStop: BusStop?

    /// 정류장 선택 시 호출되는 콜백 함수
    let onBusStopSelected: (BusStop) -> Void

    /// ViewModel - 근처 정류장 데이터를 관리
    @StateObject private var viewModel = BusStopSelectionViewModel()

    /// Sheet를 닫기 위한 Environment 변수
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            // 배경색 설정 (다크 테마)
            Color(red: 0x14 / 255, green: 0x15 / 255, blue: 0x1B / 255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 커스텀 헤더 (타이틀 + 닫기 버튼)
                headerView()

                // 상태에 따라 다른 UI 표시
                contentView()
            }
        }
        .onAppear {
            // View가 나타날 때 근처 정류장 로드
            viewModel.fetchNearbyStops()
        }
    }

    // MARK: - Header View

    /// 커스텀 헤더 - 타이틀과 닫기 버튼
    private func headerView() -> some View {
        VStack {
            ZStack {
                Text("정류장 변경")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                HStack {
                    Spacer()

                    Button {
                        dismiss() // Sheet 닫기
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0x14 / 255, green: 0x15 / 255, blue: 0x1B / 255))

            HStack {
                Text("주변 정류장")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            Divider()
        }
    }

    // MARK: - Content View

    /// 상태에 따라 적절한 UI를 반환하는 함수
    @ViewBuilder
    private func contentView() -> some View {
        if viewModel.isLoading {
            // 1. 로딩 중: ProgressView 표시
            loadingView()
        } else if let errorMessage = viewModel.errorMessage {
            // 2. 에러 발생: 에러 메시지 + 재시도 버튼
            errorView(message: errorMessage)
        } else if viewModel.nearbyStops.isEmpty {
            // 3. 정류장 없음: 안내 메시지
            emptyView()
        } else {
            // 4. 정상: 정류장 리스트 표시
            stopListView()
        }
    }

    // MARK: - Loading View

    /// 로딩 중 UI
    private func loadingView() -> some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .accessibilityLabel("근처 정류장을 불러오는 중입니다")
            Spacer()
        }
    }

    // MARK: - Error View

    /// 에러 발생 시 UI
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                // 에러 메시지 텍스트
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // 재시도 버튼
                Button {
                    viewModel.fetchNearbyStops()
                } label: {
                    Text("다시 시도")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Capsule().fill(Color.blue))
                }
            }
            .padding()

            Spacer()
        }
    }

    // MARK: - Empty View

    /// 근처 정류장이 없을 때 UI
    private func emptyView() -> some View {
        VStack {
            Spacer()
            Text("근처에 정류장이 없습니다")
                .font(.body)
                .foregroundColor(.white)
            Spacer()
        }
    }

    // MARK: - Stop List View

    /// 정류장 리스트 UI
    private func stopListView() -> some View {
        List {
            ForEach(viewModel.nearbyStops) { stopWithDistance in // ← 변경
                Button {
                    onBusStopSelected(stopWithDistance.stop) // ← .stop으로 접근
                    dismiss()
                } label: {
                    stopRow(stopWithDistance: stopWithDistance) // ← 파라미터 변경
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color(red: 0x14 / 255, green: 0x15 / 255, blue: 0x1B / 255))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Stop Row

    /// 각 정류장 행의 UI
    private func stopRow(stopWithDistance: BusStopSelectionViewModel.StopWithDistance) -> some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) { // spacing 추가
                    // 정류장 이름
                    Text(stopWithDistance.stop.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)

                    // 정류장 번호 추가 (옵셔널 처리)
                    if let number = stopWithDistance.stop.number {
                        Text(number)
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }

            HStack {
                Spacer()
                // 거리 표시
                Text(formatDistance(stopWithDistance.distance))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.primarynormal))
                    .padding(.trailing)
            }
        }
        .padding()
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // 거리 포맷 함수 추가
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let km = meters / 1000.0
            return String(format: "%.1fkm", km)
        }
    }
}
