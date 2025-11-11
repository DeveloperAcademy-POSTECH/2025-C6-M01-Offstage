import SwiftUI

protocol LegacyRoutable: Hashable {
    associatedtype V: View
    @ViewBuilder func view() -> V
}
