import BusAPI
import SwiftUI

struct BusStopSelectionView: View {
    // MARK: - Properties

    /// 현재 선택된 정류장 (HomeView에서 전달받음)
    let currentBusStop: BusStop?

    /// 정류장 선택 시 호출되는 콜백 함수
    let onBusStopSelected: (BusStop) -> Void

    /// GPS 갱신을 위한 콜백
    let onRefresh: (() -> Void)?

    /// ViewModel - 근처 정류장 데이터를 관리
    @StateObject private var viewModel = BusStopSelectionViewModel()

    /// Sheet를 닫기 위한 Environment 변수
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            // 배경색 설정 (다크 테마)
            Color(Color(.backgroundstrong))
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
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(
                                .white,
                                Color(.backgroundmedium)
                            )
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.backgroundstrong))

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

    // MARK: - Header View

    private func gpsButtonView() -> some View {
        Button {
            onRefresh?() // 콜백 호출 (dismiss + GPS 갱신)
        } label: {
            Text("현재 위치로 찾기")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .overlay(
            RoundedRectangle(cornerRadius: 99)
                .stroke(.white, lineWidth: 2)
        )
        .cornerRadius(99)
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
                    Text(L10n.Common.Ui.buttonRetry)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(
                            Capsule().stroke(Color(.primarynormal), lineWidth: 2)
                        )
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
            Text("주변 500m 이내에 정류장이 없어요.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .padding(.top, 50)
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
                .listRowBackground(Color(.backgroundstrong))
                .listRowSeparator(.hidden)
            }
            HStack {
                Spacer()
                gpsButtonView()
                Spacer()
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.backgroundstrong))
            .padding(.top, 16)
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
                            .foregroundColor(Color(.gray200))
                    }
                }
                Spacer()

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
