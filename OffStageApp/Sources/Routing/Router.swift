import Combine
import SwiftUI

final class Router<T: Routable>: ObservableObject {
    @Published var root: T
    @Published var paths: [T] = []

    init(root: T) {
        self.root = root
    }

    // 다음 표시할 뷰 선택하기
    func push(_ route: T) {
        paths.append(route)
    }

    // 현재 보고있는 뷰를 없애고 이전 뷰로가기
    func pop() {
        guard !paths.isEmpty else { return }
        paths.removeLast()
    }

    // 쌓여있는 뷰를 다 없에고 첫 화면 표시
    func popToRoot() {
        paths.removeAll()
    }

    // 마지막 뷰를 다른 뷰로 교체
    func replace(_ route: T) {
        guard !paths.isEmpty else { push(route); return }
        paths[paths.count - 1] = route
    }

    // 특정화면까지 돌아가기(안쓸 것 같긴 하다.)
    func pop(to route: T) {
        guard let idx = paths.firstIndex(of: route) else { return }
        let n = paths.count - idx - 1
        guard n > 0 else { return }
        paths.removeLast(n)
    }
}
