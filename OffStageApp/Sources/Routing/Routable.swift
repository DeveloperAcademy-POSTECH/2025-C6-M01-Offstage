import SwiftUI

protocol Routable: Hashable {
    associatedtype V: View
    @ViewBuilder func view() -> V
}
