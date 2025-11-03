import SwiftData
import SwiftUI

struct HomeEditView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor<Favorite>(\Favorite.order),
        SortDescriptor<Favorite>(\Favorite.routeNo),
    ]) private var favorites: [Favorite]

    // 취소를 허용하기 위한 데이터의 인메모리 복사본
    @State private var editableStops: [FavoritedStop] = []
    // 초기 상태 저장
    @State private var originalStops: [FavoritedStop] = []
    @State private var hasChanges = false

    private var favoritedStops: [FavoritedStop] {
        let grouped = Dictionary(grouping: favorites, by: { $0.nodeId })
        return grouped.map { _, favorites in
            FavoritedStop(favorites: favorites)
        }.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack {
            List {
                ForEach(editableStops) { station in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(station.nodeName)
                                .font(.headline)
                            Text(station.nodeNo ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(station.favorites.map(\.routeNo).joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .onDelete(perform: deleteStations)
                .onMove(perform: moveStations)
            }
            .environment(\.editMode, .constant(.active))

            footerButtons
        }
        .onAppear(perform: setupInitialState)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("홈 화면 편집")
                    .font(.title2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var footerButtons: some View {
        HStack(spacing: 12) {
            Button(action: cancelChanges) {
                Text("취소")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(action: saveChanges) {
                Text("저장")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasChanges)
        }
        .padding()
    }

    private func setupInitialState() {
        // 영구 저장된 데이터를 편집 가능한 상태로 한 번만 로드
        if editableStops.isEmpty {
            editableStops = favoritedStops
            originalStops = favoritedStops // 초기 상태 저장
        }
    }

    private func cancelChanges() {
        editableStops = originalStops // 원래 상태로 되돌리기
        hasChanges = false // 저장할 변경 사항 없음
        // router.pop()
    }

    private func deleteStations(at offsets: IndexSet) {
        editableStops.remove(atOffsets: offsets)
        hasChanges = true
    }

    private func moveStations(from source: IndexSet, to destination: Int) {
        editableStops.move(fromOffsets: source, toOffset: destination)
        hasChanges = true
    }

    private func saveChanges() {
        // 편집 가능한 목록에 아직 있는 노드 ID 집합 생성
        let finalNodeIDs = Set(editableStops.map(\.nodeId))

        // 목록에 더 이상 없는 즐겨찾기 삭제
        for favorite in favorites {
            if !finalNodeIDs.contains(favorite.nodeId) {
                modelContext.delete(favorite)
            }
        }

        // 나머지 즐겨찾기의 순서 업데이트
        for (index, station) in editableStops.enumerated() {
            for favorite in station.favorites {
                favorite.order = index
            }
        }

        // 변경사항 저장 및 뷰 닫기
        try? modelContext.save()
        router.pop()
    }
}

extension HomeEditView {
    // 재정렬을 위해 이 구조체는 변경 가능해야함.
    struct FavoritedStop: Identifiable {
        var favorites: [Favorite]
        var id: String { (favorites.first?.nodeId ?? "") + favorites.map(\.id).joined() }
        var nodeId: String { favorites.first?.nodeId ?? "" }
        var nodeName: String { favorites.first?.nodeName ?? "" }
        var nodeNo: String? { favorites.first?.nodeNo }
        var cityCode: String { favorites.first?.cityCode ?? "" }
        var order: Int { favorites.first?.order ?? 0 }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Favorite.self, configurations: .init(isStoredInMemoryOnly: true))
        return RouterView(router: Router<AppRoute>(root: .homeedit))
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
