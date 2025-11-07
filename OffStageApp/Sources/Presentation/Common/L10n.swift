import SwiftUI

// [주의] 이 파일은 스크립트에 의해 자동 생성되었습니다.
// L10n(현지화) 및 A11y(접근성) 문자열을 관리합니다.
// 원본 소스: Scripts/strings.csv

enum L10n {
    private static func key(_ key: String) -> LocalizedStringKey {
        LocalizedStringKey(key)
    }

    enum Arbitrary {
        /// "임의의 값" (문맥: 임의의 테스트 값)
        static let sample = key("arbitrary.sample")
    }

    enum BusStation {
        enum Ui {
            /// "버스 인식하기" (문맥: 버스 정류장 화면: 버스 인식 버튼)
            static let buttonRecognizeBus = key("busStation.ui.button.recognizeBus")

            /// "정류장 정보를 불러오지 못했습니다." (문맥: 정류장 상세: 로드 실패 에러)
            static let errorFailedToLoad = key("busStation.ui.error.failedToLoad")

            /// "도착 예정 정보가 없습니다." (문맥: 정류장 상세: 도착 정보 없음 에러)
            static let errorNoArrivalInfo = key("busStation.ui.error.noArrivalInfo")

            /// "경유 노선 정보를 찾을 수 없습니다." (문맥: 정류장 상세: 경유 노선 없음 에러)
            static let errorNoRoutes = key("busStation.ui.error.noRoutes")

            /// "자주 이용하는 버스를 등록해 주세요." (문맥: 정류장 상세: 즐겨찾기 유도)
            static let guidance = key("busStation.ui.guidance")
        }
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

            /// "Debug Logs" (문맥: 디버그: 화면 타이틀)
            static let title = key("debug.ui.title")
        }
    }

    enum Home {
        enum Ui {
            /// "편집" (문맥: 홈 화면: 편집 버튼)
            static let buttonEdit = key("home.ui.button.edit")

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

    enum HomeEdit {
        enum Ui {
            /// "즐겨찾기 편집" (문맥: 즐겨찾기 편집: 내비게이션 타이틀)
            static let title = key("homeEdit.ui.title")
        }
    }

    enum K {
        /// "버스온다" (문맥: 앱의 공식 이름)
        static let appName = key("k.appName")
    }

    enum Onboarding {
        enum Ui {
            /// "시작하기" (문맥: 온보딩 권한: 앱 시작 버튼)
            static let buttonStartApp = key("onboarding.ui.button.startApp")

            /// "알아보기" (문맥: 온보딩 시작: 알아보기 버튼)
            static let buttonStartCTA = key("onboarding.ui.button.startCTA")

            /// "버스 번호 인식을 위해 사용" (문맥: 온보딩 권한: 카메라 사용 이유)
            static let descriptionCamera = key("onboarding.ui.description.camera")

            /// "위치 기반 정류장 안내를 위해 사용" (문맥: 온보딩 권한: 위치 정보 사용 이유)
            static let descriptionLocation = key("onboarding.ui.description.location")

            /// "음성 검색 기능을 위해 사용" (문맥: 온보딩 권한: 마이크 사용 이유)
            static let descriptionMicrophone = key("onboarding.ui.description.microphone")

            /// "시작하기 전에" (문맥: 온보딩 권한: 상단 헤더)
            static let headerPermissions = key("onboarding.ui.header.permissions")

            /// "카메라" (문맥: 온보딩 권한: 카메라 레이블)
            static let labelCamera = key("onboarding.ui.label.camera")

            /// "위 권한 사용에 동의하지 않는 경우 앱 사용이 제한됩니다." (문맥: 온보딩 권한: 미동의 시 안내)
            static let labelDisclaimer = key("onboarding.ui.label.disclaimer")

            /// "위치 정보" (문맥: 온보딩 권한: 위치 정보 레이블)
            static let labelLocation = key("onboarding.ui.label.location")

            /// "마이크" (문맥: 온보딩 권한: 마이크 레이블)
            static let labelMicrophone = key("onboarding.ui.label.microphone")

            /// "더 나은 앱 사용을 위해 동의가 필요한 권한을 확인해주세요." (문맥: 온보딩 권한: 부제목)
            static let subtitlePermissions = key("onboarding.ui.subtitle.permissions")

            /// "탑승하려는 버스를 즐겨찾기 하면 버스 인식을 시작할 수 있 습니다." (문맥: 온보딩 1페이지 문구)
            static let titlePage1 = key("onboarding.ui.title.page1")

            /// "버스 인식 카메라로 버스 번호 를 확인할 수 있습니다. " (문맥: 온보딩 2페이지 문구)
            static let titlePage2 = key("onboarding.ui.title.page2")

            /// "즐겨찾기한 버스는 홈화면에 서 빠르게 버스인식을 할 수 있 습니다." (문맥: 온보딩 3페이지 문구)
            static let titlePage3 = key("onboarding.ui.title.page3")

            /// "권한 요청" (문맥: 온보딩 권한: 내비게이션 타이틀)
            static let titlePermissions = key("onboarding.ui.title.permissions")

            /// "필수 접근 권한" (문맥: 온보딩 권한: 필수 권한 섹션 타이틀)
            static let titleRequiredAccess = key("onboarding.ui.title.requiredAccess")

            /// "는 저시력자를 위한 버스 안내 앱입니다." (문맥: 온보딩 시작: 앱 설명 (앱 이름 뒤에 붙음))
            static let titleStart = key("onboarding.ui.title.start")
        }
    }

    enum QuickCamera {
        enum Ui {
            /// "빠른 카메라" (문맥: 빠른 카메라 화면: 타이틀)
            static let title = key("quickCamera.ui.title")
        }
    }

    enum Search {
        enum Ui {
            /// "표시할 정류장이 없습니다." (문맥: 검색 화면: 주변 정류장 없을 때)
            static let emptyNoStops = key("search.ui.empty.noStops")

            /// "검색..." (문맥: 검색 화면: 검색창 플레이스홀더)
            static let placeholder = key("search.ui.placeholder")

            /// "ID:" (문맥: 검색 결과: 정류장 ID 접두사)
            static let prefixStopID = key("search.ui.prefix.stopID")

            /// "주변 정류장" (문맥: 검색 화면: 주변 정류장 섹션 타이틀)
            static let titleNearbyStops = key("search.ui.title.nearbyStops")
        }
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
