import SwiftUI

extension LocalizedStringKey {
    /// LocalizedStringKey의 문자열 값을 반환합니다.
    /// String(format:)과 같이 String이 명시적으로 필요한 경우에 유용합니다.
    var string: String {
        // LocalizedStringKey에서 String 값을 가져오기 위한 일반적인 해결 방법입니다.
        // Text 뷰를 생성한 다음 해당 콘텐츠를 추출합니다.
        // 루프에서 성능에 이상적이지 않을 수 있지만 접근성 알림에는 허용됩니다.
        // 실제 앱에서는 전용 로컬라이제이션 관리자를 사용해야 합니다.
        let mirror = Mirror(reflecting: self)
        let children = mirror.children

        if let storage = children.first(where: { $0.label == "storage" })?.value {
            let storageMirror = Mirror(reflecting: storage)
            let storageChildren = storageMirror.children

            if let literal = storageChildren.first(where: { $0.label == "literal" })?.value as? String {
                return literal
            }
            // 리터럴을 직접 사용할 수 없는 경우(예: 보간된 문자열)에 대한 대체 처리입니다.
            if let key = storageChildren.first(where: { $0.label == "key" })?.value as? String {
                return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
            }
        }
        return "" // Fallback
    }
}
