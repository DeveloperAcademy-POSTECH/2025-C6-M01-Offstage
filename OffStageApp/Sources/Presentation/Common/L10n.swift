import SwiftUI

// [주의] 이 파일은 스크립트에 의해 자동 생성되었습니다.
// L10n(현지화) 및 A11y(접근성) 문자열을 관리합니다.
// 원본 소스: Scripts/strings.csv

enum L10n {
    private static func key(_ key: String) -> LocalizedStringKey {
        LocalizedStringKey(key)
    }

    enum Common {
        enum Ui {
            /// "취소" (문맥: 공용: 취소 버튼)
            static let buttonCancel = key("common.ui.button.cancel")

            /// "다음" (문맥: 공용: 다음 버튼)
            static let buttonNext = key("common.ui.button.next")

            /// "이전" (문맥: 공용: 이전 버튼)
            static let buttonPrevious = key("common.ui.button.previous")

            /// "다시 시도" (문맥: 공용: 재시도 버튼)
            static let buttonRetry = key("common.ui.button.retry")

            /// "저장" (문맥: 공용: 저장 버튼)
            static let buttonSave = key("common.ui.button.save")
        }
    }

    enum Debug {
        enum Ui {
            /// "Api Test View" (문맥: 디버그: Api 테스트 뷰 이동 버튼)
            static let buttonApiTest = key("debug.ui.button.apiTest")

            /// "Clear" (문맥: 디버그: 로그 지우기 버튼)
            static let buttonClear = key("debug.ui.button.clear")

            /// "STT & TTS Test View" (문맥: 디버그: STT/TTS 테스트 뷰 이동 버튼)
            static let buttonSttTtsTest = key("debug.ui.button.sttTtsTest")

            /// "207, 306" (문맥: 디버그: 버스 비전 테스트 링크)
            static let linkBusVision = key("debug.ui.link.busVision")

            /// "Debug" (문맥: 디버그: 화면 타이틀)
            static let title = key("debug.ui.title")
        }
    }

    enum Home {
        enum Ui {
            /// "나의 버스 추가하기" (문맥: 홈 화면: 즐겨찾기 비어있을 때 추가 버튼)
            static let emptyButtonAdd = key("home.ui.empty.button.add")

            /// "자주 이용하는 버스를 추가해 주세요." (문맥: 홈 화면: 즐겨찾기 비어있을 때 부제목)
            static let emptySubtitle = key("home.ui.empty.subtitle")

            /// "저장된 내역이 없습니다." (문맥: 홈 화면: 즐겨찾기 비어있을 때 제목)
            static let emptyTitle = key("home.ui.empty.title")

            /// "버스 노선, 정류장 검색" (문맥: 홈 화면: 검색창 플레이스홀더)
            static let placeholderSearch = key("home.ui.placeholder.search")

            /// "홈" (문맥: 홈 화면: 내비게이션 타이틀)
            static let title = key("home.ui.title")
        }
    }

    enum K {
        /// "버스온다" (문맥: 앱의 공식 이름)
        static let appName = key("k.appName")
    }

    enum SttTtsTest {
        enum Ui {
            /// "키보드 내리기" (문맥: STT/TTS 테스트: 키보드 내리기 버튼)
            static let buttonDismissKeyboard = key("sttTtsTest.ui.button.dismissKeyboard")

            /// "읽기" (문맥: STT/TTS 테스트: TTS 읽기 버튼)
            static let buttonRead = key("sttTtsTest.ui.button.read")

            /// "🎙️ 인식 시작" (문맥: STT/TTS 테스트: STT 인식 시작 버튼)
            static let buttonStartListening = key("sttTtsTest.ui.button.startListening")

            /// "정지" (문맥: STT/TTS 테스트: TTS 정지 버튼)
            static let buttonStop = key("sttTtsTest.ui.button.stop")

            /// "🛑 인식 중지" (문맥: STT/TTS 테스트: STT 인식 중지 버튼)
            static let buttonStopListening = key("sttTtsTest.ui.button.stopListening")

            /// "여기에 인식된 텍스트가 표시됩니다." (문맥: STT/TTS 테스트: STT 결과 플레이스홀더)
            static let placeholderStt = key("sttTtsTest.ui.placeholder.stt")

            /// "텍스트를 입력하세요" (문맥: STT/TTS 테스트: TTS 입력 플레이스홀더)
            static let placeholderTts = key("sttTtsTest.ui.placeholder.tts")

            /// "STT&TTS 테스트 페이지" (문맥: STT/TTS 테스트: 내비게이션 타이틀)
            static let titleNavigation = key("sttTtsTest.ui.title.navigation")

            /// "음성 받아적기 테스트" (문맥: STT/TTS 테스트: STT 섹션 타이틀)
            static let titleStt = key("sttTtsTest.ui.title.stt")

            /// "읽을 텍스트" (문맥: STT/TTS 테스트: TTS 섹션 타이틀)
            static let titleTts = key("sttTtsTest.ui.title.tts")
        }
    }

    enum Test {
        enum Ui {
            /// "정류장 기준 전체 도착 예정 정보" (문맥: 테스트: 정류장 도착 정보 버튼 서브타이틀)
            static let buttonArrivalsSubtitle = key("test.ui.button.arrivals.subtitle")

            /// "정류장 도착 정보" (문맥: 테스트: 정류장 도착 정보 버튼 타이틀)
            static let buttonArrivalsTitle = key("test.ui.button.arrivals.title")

            /// "정류장 + 노선 조합으로 도착 조회" (문맥: 테스트: 특정 노선 도착 정보 버튼 서브타이틀)
            static let buttonArrivalsForRouteSubtitle = key("test.ui.button.arrivalsForRoute.subtitle")

            /// "특정 노선 도착 정보" (문맥: 테스트: 특정 노선 도착 정보 버튼 타이틀)
            static let buttonArrivalsForRouteTitle = key("test.ui.button.arrivalsForRoute.title")

            /// "선택한 노선의 차량 위치 추적" (문맥: 테스트: 차량 실시간 위치 버튼 서브타이틀)
            static let buttonRouteBusLocationsSubtitle = key("test.ui.button.routeBusLocations.subtitle")

            /// "차량 실시간 위치" (문맥: 테스트: 차량 실시간 위치 버튼 타이틀)
            static let buttonRouteBusLocationsTitle = key("test.ui.button.routeBusLocations.title")

            /// "첫/막차 시간 등 노선 상세 확인" (문맥: 테스트: 노선 기본 정보 버튼 서브타이틀)
            static let buttonRouteInfoSubtitle = key("test.ui.button.routeInfo.subtitle")

            /// "노선 기본 정보" (문맥: 테스트: 노선 기본 정보 버튼 타이틀)
            static let buttonRouteInfoTitle = key("test.ui.button.routeInfo.title")

            /// "노선이 지나가는 정류장 순서 확인" (문맥: 테스트: 노선 경유 정류장 버튼 서브타이틀)
            static let buttonRouteStopsSubtitle = key("test.ui.button.routeStops.subtitle")

            /// "노선 경유 정류장" (문맥: 테스트: 노선 경유 정류장 버튼 타이틀)
            static let buttonRouteStopsTitle = key("test.ui.button.routeStops.title")

            /// "노선 번호 키워드로 노선 찾기" (문맥: 테스트: 노선 번호 검색 버튼 서브타이틀)
            static let buttonSearchRouteSubtitle = key("test.ui.button.searchRoute.subtitle")

            /// "노선 번호 검색" (문맥: 테스트: 노선 번호 검색 버튼 타이틀)
            static let buttonSearchRouteTitle = key("test.ui.button.searchRoute.title")

            /// "도시 코드와 정류장 이름으로 조회" (문맥: 테스트: 정류장 키워드 검색 버튼 서브타이틀)
            static let buttonSearchStopSubtitle = key("test.ui.button.searchStop.subtitle")

            /// "정류장 키워드 검색" (문맥: 테스트: 정류장 키워드 검색 버튼 타이틀)
            static let buttonSearchStopTitle = key("test.ui.button.searchStop.title")

            /// "선택한 정류장을 통과하는 노선 목록" (문맥: 테스트: 정류장을 지나는 노선 버튼 서브타이틀)
            static let buttonStopRoutesSubtitle = key("test.ui.button.stopRoutes.subtitle")

            /// "정류장을 지나는 노선" (문맥: 테스트: 정류장을 지나는 노선 버튼 타이틀)
            static let buttonStopRoutesTitle = key("test.ui.button.stopRoutes.title")

            /// "현재 좌표 기준으로 반경 검색" (문맥: 테스트: 현위치 주변 정류장 버튼 서브타이틀)
            static let buttonStopsByGpsSubtitle = key("test.ui.button.stopsByGps.subtitle")

            /// "현위치 주변 정류장" (문맥: 테스트: 현위치 주변 정류장 버튼 타이틀)
            static let buttonStopsByGpsTitle = key("test.ui.button.stopsByGps.title")

            /// "테스트 API 호출" (문맥: 테스트: API 호출 섹션 타이틀)
            static let labelApiCall = key("test.ui.label.apiCall")

            /// "cityCode" (문맥: 테스트: cityCode 레이블)
            static let labelCityCode = key("test.ui.label.cityCode")

            /// "위도/경도" (문맥: 테스트: 위도/경도 레이블)
            static let labelCoordinates = key("test.ui.label.coordinates")

            /// "nodeId" (문맥: 테스트: nodeId 레이블)
            static let labelNodeId = key("test.ui.label.nodeId")

            /// "원본 응답(JSON)" (문맥: 테스트: 원본 응답 레이블)
            static let labelRawResponse = key("test.ui.label.rawResponse")

            /// "응답 미리보기" (문맥: 테스트: 응답 미리보기 레이블)
            static let labelResponsePreview = key("test.ui.label.responsePreview")

            /// "노선 ID/노선 번호" (문맥: 테스트: 노선 레이블)
            static let labelRoute = key("test.ui.label.route")

            /// "검색어" (문맥: 테스트: 검색어 레이블)
            static let labelSearchTerm = key("test.ui.label.searchTerm")

            /// "검색어 없음" (문맥: 테스트: 검색어 없음 플레이스홀더)
            static let placeholderNoSearchTerm = key("test.ui.placeholder.noSearchTerm")

            /// "도착 정보" (문맥: 테스트: 도착 정보 섹션 타이틀)
            static let titleArrivalSection = key("test.ui.title.arrivalSection")

            /// "버스 API 테스트" (문맥: 테스트: 내비게이션 타이틀)
            static let titleNavigation = key("test.ui.title.navigation")

            /// "노선 정보" (문맥: 테스트: 노선 정보 섹션 타이틀)
            static let titleRouteSection = key("test.ui.title.routeSection")

            /// "정류장 조회" (문맥: 테스트: 정류장 조회 섹션 타이틀)
            static let titleStopSection = key("test.ui.title.stopSection")
        }
    }
}
