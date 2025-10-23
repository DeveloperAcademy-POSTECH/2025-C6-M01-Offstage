import BusAPI
import SwiftUI

struct BusStationView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel: BusStationViewModel

    init(input: BusStationViewInput, busRepository: BusRepository = DefaultBusRepository()) {
        _viewModel = StateObject(wrappedValue: BusStationViewModel(input: input, busRepository: busRepository))
    }

    init(viewModel: BusStationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 안내 문구
                    Text("자주 이용하는 버스를 등록해 주세요.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.gray)

                    // 버스 리스트
                    content
                }
            }
        }
        .task { viewModel.load() }
        // TODO: arrivalDescription에 대한 동적 새로고침 로직을 구현해야 합니다.
        // 남은 시간이 길 때는 (예:25분 이상?) 5분마다 새로고침하고,
        // 시간이 줄어들수록 더 자주 새로고침해야 합니다.
        .navigationBarItems(
            trailing:
            Button(action: { router.popToRoot() }) {
                Image(systemName: "house")
            }
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.input.nodeName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(viewModel.input.nodeNumber ?? "-")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemGray6))
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ActivityIndicator(isAnimating: .constant(true), style: .large)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)

        case let .success(routes):
            if routes.isEmpty {
                Group {
                    if viewModel.input.routes.isEmpty {
                        Text("경유 노선 정보를 찾을 수 없습니다.")
                    } else {
                        Text("도착 예정 정보가 없습니다.")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.secondary)
                .padding(.vertical, 40)
            } else {
                BusStationListSubView(routes: routes, viewInput: viewModel.input)
                    .padding(.horizontal, 16)
            }

        case let .error(error):
            VStack(spacing: 12) {
                Text("정류장 정보를 불러오지 못했습니다.")
                    .foregroundColor(.secondary)
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Button("다시 시도") {
                    viewModel.refresh()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
        }
    }
}
