#if DEBUG_MODE
    import SwiftUI

    struct L10nTestView: View {
        @State private var language = "ko"

        var body: some View {
            VStack {
                Toggle(isOn: Binding(
                    get: { language == "en" },
                    set: { language = $0 ? "en" : "ko" }
                )) {
                    Text(L10n.Debug.Ui.toggleSwitchToEnglish)
                }
                .padding()

                List {
                    Section("Bus") {
                        Text(L10n.Bus.Arrival.currentBusLocation)
                        Text(L10n.Bus.Arrival.imminent)
                        Text(L10n.Bus.Arrival.noInformation)
                    }
                    Section("BusVision") {
                        Text(L10n.BusVision.Detection.confirmBusNumber)
                        Text(L10n.BusVision.Detection.confirmBusNumberPrefix)

                        Text(L10n.BusVision.Detection.inProgress)
                        Text(L10n.BusVision.Detection.retry)
                        Text(L10n.BusVision.Detection.selectFromList)
                        Text(L10n.BusVision.Detection.wrongBusNumber)
                    }
                    Section("Common") {
                        Text(L10n.Common.Confirmation.no)
                        Text(L10n.Common.Confirmation.yes)
                        Text(L10n.Common.Confirmation.yesShort)
                        Text(L10n.Common.Ui.buttonCancel)
                        Text(L10n.Common.Ui.buttonNext)
                        Text(L10n.Common.Ui.buttonPrevious)
                        Text(L10n.Common.Ui.buttonRetry)
                        Text(L10n.Common.Ui.buttonSave)
                        Text(L10n.Common.Ui.suffixIs)
                    }
                    Section("Debug") {
                        Text(L10n.Debug.Ui.buttonApiTest)
                        Text(L10n.Debug.Ui.buttonClear)
                        Text(L10n.Debug.Ui.buttonSttTtsTest)
                        Text(L10n.Debug.Ui.linkBusVision)
                        Text(L10n.Debug.Ui.title)
                    }
                    Section("Home") {
                        Text(L10n.Home.Button.findBus)
                        Text(L10n.Home.Button.findNearbyStops)
                        Text(L10n.Home.Map.near)
                        Text(L10n.Home.Map.noStopsFound)
                        Text(L10n.Home.Map.noStopsFoundSimple)
                        Text(L10n.Home.Sheet.busDetectionGuide)
                        Text(L10n.Home.Sheet.notFound)
                        Text(L10n.Home.Sheet.selectBusRoute)
                        Text(L10n.Home.Sheet.startBusDetection)
                        Text(L10n.Home.Stt.askBusNumber)
                        Text(L10n.Home.Stt.askBusNumberSimple)
                        Text(L10n.Home.Stt.confirmNearestStop)
                        Text(L10n.Home.Stt.currentNearbyStopPrefix)
                        Text(L10n.Home.Stt.listening)

                        Text(L10n.Home.Stt.searchBasedOnLocation)
                    }

                    Section("Permission") {
                        Text(L10n.Permission.Button.goToSettings)
                        Text(L10n.Permission.Camera.reason)
                        Text(L10n.Permission.Camera.title)
                        Text(L10n.Permission.Location.reason)
                        Text(L10n.Permission.Location.title)
                        Text(L10n.Permission.Mic.reason)
                        Text(L10n.Permission.Mic.title)
                        Text(L10n.Permission.Prompt.all)
                        Text(L10n.Permission.Prompt.title)
                    }

                    Section("SttTtsTest") {
                        Text(L10n.SttTtsTest.Ui.buttonDismissKeyboard)
                        Text(L10n.SttTtsTest.Ui.buttonRead)
                        Text(L10n.SttTtsTest.Ui.buttonStartListening)
                        Text(L10n.SttTtsTest.Ui.buttonStop)
                        Text(L10n.SttTtsTest.Ui.buttonStopListening)
                        Text(L10n.SttTtsTest.Ui.placeholderStt)
                        Text(L10n.SttTtsTest.Ui.placeholderTts)
                        Text(L10n.SttTtsTest.Ui.titleNavigation)
                        Text(L10n.SttTtsTest.Ui.titleStt)
                        Text(L10n.SttTtsTest.Ui.titleTts)
                    }
                    Section("Test") {
                        Text(L10n.Test.Ui.buttonArrivalsSubtitle)
                        Text(L10n.Test.Ui.buttonArrivalsTitle)
                        Text(L10n.Test.Ui.buttonArrivalsForRouteSubtitle)
                        Text(L10n.Test.Ui.buttonArrivalsForRouteTitle)
                        Text(L10n.Test.Ui.buttonRouteBusLocationsSubtitle)
                        Text(L10n.Test.Ui.buttonRouteBusLocationsTitle)
                        Text(L10n.Test.Ui.buttonRouteInfoSubtitle)
                        Text(L10n.Test.Ui.buttonRouteInfoTitle)
                        Text(L10n.Test.Ui.buttonRouteStopsSubtitle)
                        Text(L10n.Test.Ui.buttonRouteStopsTitle)
                        Text(L10n.Test.Ui.buttonSearchRouteSubtitle)
                        Text(L10n.Test.Ui.buttonSearchRouteTitle)
                        Text(L10n.Test.Ui.buttonSearchStopSubtitle)
                        Text(L10n.Test.Ui.buttonSearchStopTitle)
                        Text(L10n.Test.Ui.buttonStopRoutesSubtitle)
                        Text(L10n.Test.Ui.buttonStopRoutesTitle)
                        Text(L10n.Test.Ui.buttonStopsByGpsSubtitle)
                        Text(L10n.Test.Ui.buttonStopsByGpsTitle)
                        Text(L10n.Test.Ui.labelApiCall)
                        Text(L10n.Test.Ui.labelCityCode)
                        Text(L10n.Test.Ui.labelCoordinates)
                        Text(L10n.Test.Ui.labelNodeId)
                        Text(L10n.Test.Ui.labelRawResponse)
                        Text(L10n.Test.Ui.labelResponsePreview)
                        Text(L10n.Test.Ui.labelRoute)
                        Text(L10n.Test.Ui.labelSearchTerm)
                        Text(L10n.Test.Ui.placeholderNoSearchTerm)
                        Text(L10n.Test.Ui.titleArrivalSection)
                        Text(L10n.Test.Ui.titleNavigation)
                        Text(L10n.Test.Ui.titleRouteSection)
                        Text(L10n.Test.Ui.titleStopSection)
                    }
                }
                .environment(\.locale, .init(identifier: language))
            }
            .navigationTitle(L10n.Debug.Ui.titleL10nTest)
        }
    }
#endif
