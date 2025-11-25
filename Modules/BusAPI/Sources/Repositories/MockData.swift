import Foundation

enum MockData {
    static let stopsNearby = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "citycode": 37010,
                "nodenm": "포스텍",
                "gpslati": 36.015169,
                "nodeid": "PHB350099003",
                "gpslong": 129.325127,
                "nodeno": 299003
              },
              {
                "citycode": 37010,
                "nodenm": "생명공학연구소",
                "gpslati": 36.012563,
                "nodeid": "PHB350099002",
                "gpslong": 129.326489,
                "nodeno": 299002
              },
              {
                "citycode": 37010,
                "nodenm": "포스텍",
                "gpslati": 36.016082,
                "nodeid": "PHB350099016",
                "gpslong": 129.324605,
                "nodeno": 299016
              },
              {
                "citycode": 37010,
                "nodenm": "생명공학연구소",
                "gpslati": 36.011751,
                "nodeid": "PHB350099017",
                "gpslong": 129.326565,
                "nodeno": 299017
              },
              {
                "citycode": 37010,
                "nodenm": "효곡동행정복지센터",
                "gpslati": 36.010473,
                "nodeid": "PHB350099001",
                "gpslong": 129.328355,
                "nodeno": 299001
              }
            ]
          },
          "totalCount": 5,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let stopRoutes = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "routeid": "PHB350000231",
                "startnodenm": "양덕행",
                "routeno": "207(기본)",
                "endnodenm": "양덕행",
                "routetp": "간선버스"
              },
              {
                "routeid": "PHB350000235",
                "startnodenm": "문덕행",
                "routeno": "306(기본)",
                "endnodenm": "문덕행",
                "routetp": "간선버스"
              }
            ]
          },
          "totalCount": 2,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let stopArrivals = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": {
              "nodeid": "PHB350099003",
              "nodenm": "포스텍",
              "routetp": "간선버스",
              "arrprevstationcnt": 6,
              "routeid": "PHB350000231",
              "arrtime": 300,
              "routeno": "207(기본)",
              "vehicletp": "저상버스"
            }
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let routeArrivals = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": {
              "nodeid": "PHB350099003",
              "nodenm": "포스텍",
              "routetp": "간선버스",
              "arrprevstationcnt": 6,
              "routeid": "PHB350000231",
              "arrtime": 300,
              "routeno": "207(기본)",
              "vehicletp": "저상버스"
            }
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let routeLocations = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "nodeid": "PHB350087178",
                "nodenm": "문덕마을회관",
                "routetp": "간선버스",
                "vehicleno": 1118,
                "nodeord": 5,
                "gpslati": 129.406425,
                "gpslong": 35.95358,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350097009",
                "nodenm": "청림초등학교",
                "routetp": "간선버스",
                "vehicleno": 1117,
                "nodeord": 32,
                "gpslati": 129.404846,
                "gpslong": 35.993605,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350000011",
                "nodenm": "대잠사거리",
                "routetp": "간선버스",
                "vehicleno": 1310,
                "nodeord": 48,
                "gpslati": 129.343966,
                "gpslong": 36.011553,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350099013",
                "nodenm": "산책로",
                "routetp": "간선버스",
                "vehicleno": 1347,
                "nodeord": 61,
                "gpslati": 129.320288,
                "gpslong": 36.026408,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350099189",
                "nodenm": "LG빌라",
                "routetp": "간선버스",
                "vehicleno": 1306,
                "nodeord": 78,
                "gpslati": 129.31438,
                "gpslong": 36.028269,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350000017",
                "nodenm": "시청",
                "routetp": "간선버스",
                "vehicleno": 1322,
                "nodeord": 88,
                "gpslati": 129.340727,
                "gpslong": 36.018006,
                "routenm": "306(기본)"
              },
              {
                "nodeid": "PHB350087016",
                "nodenm": "구정3리",
                "routetp": "간선버스",
                "vehicleno": 1257,
                "nodeord": 107,
                "gpslati": 129.412562,
                "gpslong": 35.978774,
                "routenm": "306(기본)"
              }
            ]
          },
          "totalCount": 7,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let routeStations = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "nodeid": "PHB350099003",
                "nodenm": "포스텍",
                "gpslati": 36.015169,
                "gpslong": 129.325127
              },
              {
                "nodeid": "PHB350099002",
                "nodenm": "생명공학연구소",
                "gpslati": 36.012563,
                "gpslong": 129.326489
              }
            ]
          },
          "totalCount": 2,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let routeInfo = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": {
              "routeid": "PHB350000231",
              "routeno": "207(기본)"
            }
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let searchStops = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "citycode": 37010,
                "nodenm": "포스텍",
                "gpslati": 36.015169,
                "nodeid": "PHB350099003",
                "gpslong": 129.325127,
                "nodeno": 299003
              }
            ]
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let searchRoutes = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "routeid": "PHB350000231",
                "routeno": "207(기본)"
              }
            ]
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """

    static let cities = """
    {
      "response": {
        "body": {
          "numOfRows": 10,
          "items": {
            "item": [
              {
                "citycode": 37010,
                "citynm": "포항시"
              }
            ]
          },
          "totalCount": 1,
          "pageNo": 1
        },
        "header": {
          "resultCode": "00",
          "resultMsg": "NORMAL SERVICE."
        }
      }
    }
    """
}
