import Foundation

enum APIKeyProvider {
    static var busServiceKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "Bus Service Key") as? String else {
            fatalError("Info.plist에 Bus Service Key가 설정되지 않았습니다.")
        }
        print(key)
        return key
    }
}
