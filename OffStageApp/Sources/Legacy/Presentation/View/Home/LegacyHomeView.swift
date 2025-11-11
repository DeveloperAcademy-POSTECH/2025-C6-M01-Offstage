import BusAPI
import SwiftData
import SwiftUI
import UIKit

struct LegacyHomeView: View {
    @EnvironmentObject var router: LegacyRouter<AppRoute>
    @Environment(\.modelContext) private var modelContext
    @State private var locationProvider: LocationProviding = LocationManager()
    @StateObject private var permissionManager = PermissionManager()
    @State private var refreshTrigger = UUID()
    @State private var countdown: Int = 10
    @State private var timer: Timer?
    @State private var rotationAngle: Angle = .zero

    @Query(sort: [
        SortDescriptor<Favorite>(\.order),
    ]) private var favorites: [Favorite]

    private var favoritedStops: [FavoritedStop] {
        let grouped = Dictionary(grouping: favorites, by: { $0.nodeId })
        return grouped.map { _, favorites in
            FavoritedStop(favorites: favorites)
        }.sorted { $0.order < $1.order }
    }

    private var hasRequestedPermissions: Bool {
        UserDefaults.standard.bool(forKey: "hasRequestedPermissions")
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HStack {
                    Button {
                        // 검색 페이지로 이동
                        router.push(.search)
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .accessibilityHidden(true)

                            Text(L10n.Home.Ui.placeholderSearch)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding()

                    Button {
                        router.push(.quickCamera)
                    } label: {
                        Image("quickFindBus")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                }
                .background(.gray.opacity(0.1))

                ScrollView {
                    Text(L10n.Home.Ui.title)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                        .padding(.horizontal)

                    if !favoritedStops.isEmpty {
                        ForEach(favoritedStops) { station in
                            BusStationCardSubView(
                                stationName: station.nodeName,
                                stationNumber: station.nodeNo ?? "",
                                nodeId: station.nodeId,
                                cityCode: station.cityCode,
                                favorites: station.favorites,
                                refreshTrigger: refreshTrigger
                            )
                            .padding(.horizontal)
                        }

                        Button(L10n.Home.Ui.buttonEdit) {
                            router.push(.homeEdit)
                        }
                        .padding(.bottom)
                    } else {
                        Text(L10n.Home.Ui.emptyTitle)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                            .padding(.bottom)
                        Text(L10n.Home.Ui.emptySubtitle)
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)

                        Button {
                            router.push(.search)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("추가하기")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            .foregroundColor(Color(.primarynormal))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .stroke(Color(.primarynormal), lineWidth: 2)
                            )
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                if !hasRequestedPermissions {
                    Task {
                        await permissionManager.requestAll()
                        UserDefaults.standard.set(true, forKey: "hasRequestedPermissions")
                    }
                }
                startTimer()
            }
            .onDisappear(perform: stopTimer)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // 앱이 foreground로 돌아올 때 권한 재확인
                Task {
                    await permissionManager.checkAllPermissionsGranted()
                }
            }
            .sheet(isPresented: $permissionManager.showPermissionDeniedSheet) {
                PermissionSubView(
                    deniedPermissions: permissionManager.deniedPermissions,
                    grantedPermissions: permissionManager.grantedPermissions()
                )
                .interactiveDismissDisabled(true)
            }

            if !favoritedStops.isEmpty {
                RefreshButton(countdown: countdown, rotationAngle: $rotationAngle) {
                    refreshTrigger = UUID()
                    resetTimer()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        rotationAngle += .degrees(360)
                    }
                }
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                refreshTrigger = UUID()
                countdown = 10
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotationAngle += .degrees(360)
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        countdown = 10
        startTimer()
    }
}

extension LegacyHomeView {
    struct FavoritedStop: Identifiable {
        let favorites: [Favorite]
        var id: String { (favorites.first?.nodeId ?? "") + favorites.map(\.id).joined() }
        var nodeId: String { favorites.first?.nodeId ?? "" }
        var nodeName: String { favorites.first?.nodeName ?? "" }
        var nodeNo: String? { favorites.first?.nodeNo }
        var cityCode: String { favorites.first?.cityCode ?? "" }
        var order: Int { favorites.first?.order ?? 0 }
    }
}
