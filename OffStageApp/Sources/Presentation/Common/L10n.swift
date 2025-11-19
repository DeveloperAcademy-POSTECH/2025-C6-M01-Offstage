import SwiftUI

// [주의] 이 파일은 스크립트에 의해 자동 생성되었습니다.
// L10n(현지화) 및 A11y(접근성) 문자열을 관리합니다.
// 원본 소스: Scripts/strings.csv

enum L10n {
    private static func key(_ key: String) -> LocalizedStringKey {
        LocalizedStringKey(key)
    }

    enum Bus {
        enum Arrival {
            /// "현재 운행중인 버스 위치:"
            static let currentBusLocation = key("bus.arrival.currentBusLocation")
            /// "도착 예정"
            static let imminent = key("bus.arrival.imminent")
            /// "도착 예정 정보 없음"
            static let noInformation = key("bus.arrival.noInformation")

            /// "현재는 운행중인 노선이 없습니다."
            static let noOperatingRoutes = key("bus.arrival.noOperatingRoutes")

            enum Error {
                /// "도착 정보를 불러오는 데 실패했습니다: %@"
                static let loadFailed = key("bus.arrival.error.loadFailed")
            }
        }
    }

    enum BusVision {
        enum Detection {
            /// "번이 맞나요?"
            static let confirmBusNumber = key("busVision.detection.confirmBusNumber")
            /// "타려는 버스 번호가\\n"
            static let confirmBusNumberPrefix = key("busVision.detection.confirmBusNumberPrefix")

            /// "버스 인식 중"
            static let inProgress = key("busVision.detection.inProgress")
            /// "아니요, 다시 인식할게요"
            static let retry = key("busVision.detection.retry")
            /// "아니요, 목록에서 고를게요"
            static let selectFromList = key("busVision.detection.selectFromList")
            /// "다른 번호의 버스입니다."
            static let wrongBusNumber = key("busVision.detection.wrongBusNumber")
        }

        enum Debug {
            /// "%@번 탐지중" (문맥: 버스비전: 디버그 탐지 상태)
            static let detectingWithNumber = key("busVision.debug.detectingWithNumber")
        }
    }

    enum Common {
        enum Confirmation {
            /// "아니오"
            static let no = key("common.confirmation.no")
            /// "네, 맞아요."
            static let yes = key("common.confirmation.yes")
            /// "예"
            static let yesShort = key("common.confirmation.yesShort")
        }

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

            /// " 입니다."
            static let suffixIs = key("common.ui.suffix.is")

            /// "알 수 없는 위치" (문맥: 공용: 위치 정보 미확인 시 표시)
            static let unknownLocation = key("common.ui.unknownLocation")
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

            /// "API Flow" (문맥: 디버그: MVP 테스트 내비게이션 타이틀)
            static let titleApiFlow = key("debug.ui.title.apiFlow")

            /// "L10n Test" (문맥: 디버그: L10n 테스트 화면 타이틀)
            static let titleL10nTest = key("debug.ui.title.l10nTest")

            /// "Switch to English" (문맥: 디버그: 언어 전환 토글 레이블)
            static let toggleSwitchToEnglish = key("debug.ui.toggle.switchToEnglish")
        }

        enum Mvp {
            /// "예: 441" (문맥: 디버그: 노선 입력 예시)
            static let placeholderRouteExample = key("debug.mvp.placeholder.routeExample")

            /// "**%@** 정류장을 통과하는 버스 번호를 입력하세요." (문맥: 디버그: 노선 입력 안내)
            static let promptEnterRouteForStop = key("debug.mvp.prompt.enterRouteForStop")
        }
    }

    enum Home {
        enum Button {
            /// "버스 찾기"
            static let findBus = key("home.button.findBus")
            /// "주변 정류장 찾기"
            static let findNearbyStops = key("home.button.findNearbyStops")
        }

        enum Map {
            /// "%@ 인근"
            static let near = key("home.map.near")
            /// "주변 탐색된 정류장이\\n없습니다."
            static let noStopsFound = key("home.map.noStopsFound")
            /// "주변에 정류장이 없습니다."
            static let noStopsFoundSimple = key("home.map.noStopsFound.simple")
        }

        enum Sheet {
            /// "버스가 두번째 전 정류장에서 출발하면\\n버스 인식을 시작할 수 있어요."
            static let busDetectionGuide = key("home.sheet.busDetectionGuide")
            /// "목록에 없어요."
            static let notFound = key("home.sheet.notFound")
            /// "노선 번호를 선택하세요."
            static let selectBusRoute = key("home.sheet.selectBusRoute")
            /// "버스 인식하기"
            static let startBusDetection = key("home.sheet.startBusDetection")
        }

        enum Stt {
            /// "몇 번 버스를\\n탑승하시나요?"
            static let askBusNumber = key("home.stt.askBusNumber")
            /// "몇번 버스를 탑승하시나요?"
            static let askBusNumberSimple = key("home.stt.askBusNumberSimple")
            /// "가장 가까운 정류장은 **%@** 입니다. 맞습니까?"
            static let confirmNearestStop = key("home.stt.confirmNearestStop")
            /// "현재 주변 정류장은\\n"
            static let currentNearbyStopPrefix = key("home.stt.currentNearbyStopPrefix")
            /// "번호를 듣는중이에요."
            static let listening = key("home.stt.listening")

            /// "현재 위치를 기반으로 버스 정보를 검색합니다."
            static let searchBasedOnLocation = key("home.stt.searchBasedOnLocation")
        }

        enum A11y {
            enum Button {
                enum Mic {
                    /// "타야할 버스 번호 음성 입력 버튼"
                    static let label = key("home.a11y.button.mic.label")

                    enum Hint {
                        /// "아직 주변 정류장을 찾는 중입니다. 잠시만 기다려주세요."
                        static let loading = key("home.a11y.button.mic.hint.loading")
                        /// "주변 정류장을 찾지 못했습니다. 위치 권한을 확인하거나 다시 시도해 주세요."
                        static let noStop = key("home.a11y.button.mic.hint.noStop")
                        /// "음성으로 타야할 버스를 검색하려면 두 번 탭해주세요."
                        static let ready = key("home.a11y.button.mic.hint.ready")
                    }
                }
            }

            enum Announcement {
                /// "주변 정류장 정보를 불러오고 있습니다."
                static let loading = key("home.a11y.announcement.loading")
                /// "근처 정류장 정보를 불러오고 있습니다."
                static let loadingNearby = key("home.a11y.announcement.loadingNearby")
            }
        }

        enum Ui {}
    }

    enum Permission {
        enum Button {
            /// "설정으로 이동"
            static let goToSettings = key("permission.button.goToSettings")
        }

        enum Camera {
            /// "버스 번호 인식을 위해 사용"
            static let reason = key("permission.camera.reason")
            /// "카메라 접근"
            static let title = key("permission.camera.title")
        }

        enum Location {
            /// "사용자 위치 기반 정류장 안내를 위해 사용"
            static let reason = key("permission.location.reason")
            /// "위치 정보 접근"
            static let title = key("permission.location.title")
        }

        enum Mic {
            /// "음성 검색 기능을 위해 사용"
            static let reason = key("permission.mic.reason")
            /// "마이크 접근"
            static let title = key("permission.mic.title")
        }

        enum Prompt {
            /// "버스온다를 사용하고 정보를\\n위치, 카메라 및 마이크 접근을 허용해 주세요."
            static let all = key("permission.prompt.all")
            /// "버스온다에 접근\\n권한이 필요합니다."
            static let title = key("permission.prompt.title")
        }

        enum A11y {
            enum Status {
                /// "거절됨"
                static let denied = key("permission.a11y.status.denied")
                /// "승인됨"
                static let granted = key("permission.a11y.status.granted")
            }
        }
    }

    // Accessibility-only formats for BusArrival screens
    enum BusArrival {
        enum A11y {
            enum Format {
                /// "%@번"
                static let routeNumber = key("busArrival.a11y.format.routeNumber")
                /// "도착 예정"
                static let arriving = key("busArrival.a11y.format.arriving")
                /// "도착"
                static let arrived = key("busArrival.a11y.format.arrived")
                /// "%@번째전 정류장에서 출발했습니다."
                static let stopsAway = key("busArrival.a11y.format.stopsAway")
                /// "전 정류장에서 출발했습니다."
                static let previousStop = key("busArrival.a11y.format.previousStop")
                /// "잠시 후"
                static let soon = key("busArrival.a11y.format.soon")
                /// "정보 없음"
                static let noInfo = key("busArrival.a11y.format.noInfo")
                /// "%@분 %@초 후"
                static let minutesSeconds = key("busArrival.a11y.format.minutesSeconds")
                /// "%@초 후"
                static let seconds = key("busArrival.a11y.format.seconds")
            }
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

            /// "Seoul API Tests" (문맥: 테스트: 서울 API 테스트 섹션 타이틀)
            static let titleSeoulSection = key("test.ui.title.seoulSection")

            /// "Test Profile" (문맥: 테스트: 프로필 선택 라벨)
            static let pickerProfile = key("test.ui.picker.profile")

            /// "Seoul" (문맥: 테스트: 프로필 이름)
            static let profileSeoul = key("test.ui.profile.seoul")

            /// "Pangyo" (문맥: 테스트: 프로필 이름)
            static let profilePangyo = key("test.ui.profile.pangyo")
        }
    }

    enum K {
        /// "버스온다"
        static let appName = key("k.appName")
    }
}
