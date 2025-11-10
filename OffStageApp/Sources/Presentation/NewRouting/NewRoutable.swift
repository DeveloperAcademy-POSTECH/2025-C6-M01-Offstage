import SwiftUI

protocol NewRoutable: Hashable {
    associatedtype V: View
    @ViewBuilder func view() -> V
}
