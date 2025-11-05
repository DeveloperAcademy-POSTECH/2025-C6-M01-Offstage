// Modules/BusAPI/Sources/Network/SeoulBusDTO.swift
import Foundation

// MARK: - 정류소 GPS 검색 DTO (getStationByPos)

struct SeoulGpsStopResponse: Decodable { let msgBody: SeoulGpsStopMsgBody }
struct SeoulGpsStopMsgBody: Decodable { let itemList: [SeoulGpsStopDTO] }

struct SeoulGpsStopDTO: Decodable {
    let stationId: String // 정류소ID (-> nodeId)
    let stationNm: String // 정류소명 (-> nodeName)
    let arsId: String // 정류소번호 (-> nodeNo)
    let gpsX: String // WGS84 경도 (-> gpsLong)
    let gpsY: String // WGS84 위도 (-> gpsLati)
}

// MARK: - 정류소 키워드 검색 DTO (getStationByName)

struct SeoulKeywordStopResponse: Decodable { let msgBody: SeoulKeywordStopMsgBody }
struct SeoulKeywordStopMsgBody: Decodable { let itemList: [SeoulKeywordStopDTO] }

struct SeoulKeywordStopDTO: Decodable {
    let stId: String // 정류소ID (-> nodeId)
    let stNm: String // 정류소명 (-> nodeName)
    let arsId: String // 정류소번호 (-> nodeNo)
    let tmX: String // WGS84 경도 (-> gpsLong)
    let tmY: String // WGS84 위도 (-> gpsLati)
}

// MARK: - 정류소 상세 (도착) DTO (getStationArrivals)

//
struct SeoulArrivalResponse: Decodable { let msgBody: SeoulArrivalMsgBody }
struct SeoulArrivalMsgBody: Decodable { let itemList: [SeoulArrivalDTO] }

struct SeoulArrivalDTO: Decodable {
    let busRouteId: String // 노선ID (-> routeId)
    let rtNm: String // 노선명 (-> routeName)
    let arrmsg1: String // 첫번째 도착 메시지 (e.g., "3분후[2번째 전]")
    let arrmsg2: String // 두번째 도착 메시지
}

// MARK: - 노선 정보 DTO (getRouteInfo)

//
struct SeoulRouteInfoResponse: Decodable { let msgBody: SeoulRouteInfoMsgBody }
struct SeoulRouteInfoMsgBody: Decodable { let itemList: [SeoulRouteInfoDTO] }

struct SeoulRouteInfoDTO: Decodable {
    let busRouteId: String
    let busRouteNm: String // (-> routeName)
    let routeType: String // (-> routeType)
    let stStationNm: String // (-> startStopName)
    let edStationNm: String // (-> endStopName)
}
