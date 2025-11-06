import CoreLocation // CLPlacemark를 사용하기 위해 import
import Foundation

public enum CityCodeConverter {
    private static let cityCodeMap: [String: String] = [
        "세종특별시": "12",
        "서울특별시": "1000",
        "부산광역시": "21",
        "대구광역시": "22",
        "인천광역시": "23",
        "광주광역시": "24",
        "대전광역시/계룡시": "25",
        "울산광역시": "26",
        "제주도": "39",
        "수원시": "31010",
        "성남시": "31020",
        "의정부시": "31030",
        "안양시": "31040",
        "부천시": "31050",
        "광명시": "31060",
        "평택시": "31070",
        "동두천시": "31080",
        "안산시": "31090",
        "고양시": "31100",
        "과천시": "31110",
        "구리시": "31120",
        "남양주시": "31130",
        "오산시": "31140",
        "시흥시": "31150",
        "군포시": "31160",
        "의왕시": "31170",
        "하남시": "31180",
        "용인시": "31190",
        "파주시": "31200",
        "이천시": "31210",
        "안성시": "31220",
        "김포시": "31230",
        "화성시": "31240",
        "광주시": "31250",
        "양주시": "31260",
        "포천시": "31270",
        "여주시": "31320",
        "연천군": "31350",
        "가평군": "31370",
        "양평군": "31380",
        "춘천시": "32010",
        "원주시/횡성군": "32020",
        "태백시": "32050",
        "홍천군": "32310",
        "철원군": "32360",
        "양양군": "32410",
        "청주시": "33010",
        "충주시": "33020",
        "제천시": "33030",
        "보은군": "33320",
        "옥천군": "33330",
        "영동군": "33340",
        "진천군": "33350",
        "괴산군": "33360",
        "음성군": "33370",
        "단양군": "33380",
        "당진시": "33390",
        "천안시": "34010",
        "공주시": "34020",
        "아산시": "34040",
        "서산시": "34050",
        "논산시": "34060",
        "계룡시": "34070",
        "부여군": "34330",
        "전주시": "35010",
        "군산시": "35020",
        "정읍시": "35040",
        "남원시": "35050",
        "김제시": "35060",
        "진안군": "35320",
        "무주군": "35330",
        "장수군": "35340",
        "임실군": "35350",
        "순창군": "35360",
        "고창군": "35370",
        "부안군": "35380",
        "목포시": "36010",
        "여수시": "36020",
        "순천시": "36030",
        "나주시": "36040",
        "광양시": "36060",
        "곡성군": "36320",
        "구례군": "36330",
        "고흥군": "36350",
        "장흥군": "36380",
        "해남군": "36400",
        "영암군": "36410",
        "무안군": "36420",
        "함평군": "36430",
        "장성군": "36450",
        "완도군": "36460",
        "진도군": "36470",
        "신안군": "36480",
        "포항시": "37010",
        "경주시": "37020",
        "김천시": "37030",
        "안동시": "37040",
        "구미시": "37050",
        "영주시": "37060",
        "영천시": "37070",
        "상주시": "37080",
        "문경시": "37090",
        "경산시": "37100",
        "의성군": "37320",
        "청송군": "37330",
        "영양군": "37340",
        "영덕군": "37350",
        "청도군": "37360",
        "고령군": "37370",
        "성주군": "37380",
        "칠곡군": "37390",
        "예천군": "37400",
        "봉화군": "37410",
        "울진군": "37420",
        "울릉군": "37430",
        "창원시": "38010",
        "진주시": "38030",
        "통영시": "38050",
        "사천시": "38060",
        "김해시": "38070",
        "밀양시": "38080",
        "거제시": "38090",
        "양산시": "38100",
        "의령군": "38310",
        "함안군": "38320",
        "창녕군": "38330",
        "고성군": "38340",
        "남해군": "38350",
        "하동군": "38360",
        "산청군": "38370",
        "함양군": "38380",
        "거창군": "38390",
        "합천군": "38400",
    ]

    private static func removeRegionSuffixes(from cityName: String) -> String {
        let suffixesToRemove = ["광역시", "특별시", "시", "군", "도"]
        var cleanedName = cityName

        for suffix in suffixesToRemove {
            if cleanedName.hasSuffix(suffix) {
                cleanedName = String(cleanedName.dropLast(suffix.count))
                break
            }
        }

        // '대전광역시/계룡시' -> '대전/계룡'
        if cleanedName.contains("광역시/") {
            cleanedName = cleanedName.replacingOccurrences(of: "광역시/", with: "/")
        }

        // '원주시/횡성군' -> '원주/횡성'
        if cleanedName.contains("/") {
            cleanedName = cleanedName.replacingOccurrences(of: "시/", with: "/")
            cleanedName = cleanedName.replacingOccurrences(of: "군", with: "")
        }

        return cleanedName
    }

    /// CLPlacemark에서 cityCode(String)를 찾습니다.
    /// 서울은 "1000", 그 외 지역은 `nil`을 반환합니다.
    public static func findCode(from placemark: CLPlacemark) -> String? {
        // 1. Try to find a direct match using locality
        if let locality = placemark.locality {
            if let code = cityCodeMap[locality] {
                return code
            }
        }

        // 2. If not found, try to find a direct match using administrativeArea
        if let administrativeArea = placemark.administrativeArea {
            if let code = cityCodeMap[administrativeArea] {
                return code
            }
        }

        // 3. If still not found, try matching against components of combined city names
        //    (e.g., "대전광역시/계룡시") using cleaned names.
        let placemarkLocality = placemark.locality
        let placemarkAdminArea = placemark.administrativeArea

        for (key, value) in cityCodeMap {
            if key.contains("/") {
                let components = key.components(separatedBy: "/").map { removeRegionSuffixes(from: $0) }
                if let loc = placemarkLocality, components.contains(removeRegionSuffixes(from: loc)) {
                    return value
                }
                if let admin = placemarkAdminArea, components.contains(removeRegionSuffixes(from: admin)) {
                    return value
                }
            }
        }

        return nil
    }
}
