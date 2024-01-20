//
//  AirPollutionModel.swift
//  CleanWeather
//
//  Created by serhat on 26.12.2023.
//

import Foundation

struct AirPollutionModel {
    let aqi: String
    let so2, no2, pm10, pm25, o3, co: Double
    let lat, lon: Double
    var indexsArray: [Int] //so2 no2 pm10 pm25 o3 co
    
    init(from source: AirPollutionData) {
        aqi = String((source.list.first?.main.aqi)!)
        
        so2 = (source.list.first?.components["so2"])!
        no2 = (source.list.first?.components["no2"])!
        pm10 = (source.list.first?.components["pm10"])!
        pm25 = (source.list.first?.components["pm2_5"])!
        o3 = (source.list.first?.components["o3"])!
        co = (source.list.first?.components["co"])!
        
        lat = source.coord.lat
        lon = source.coord.lon
                
        indexsArray = [
            AirQualityIndex.getIndex(forPollutant: "so2", value: so2).rawValue,
            AirQualityIndex.getIndex(forPollutant: "no2", value: no2).rawValue,
            AirQualityIndex.getIndex(forPollutant: "pm10", value: pm10).rawValue,
            AirQualityIndex.getIndex(forPollutant: "pm25", value: pm25).rawValue,
            AirQualityIndex.getIndex(forPollutant: "o3", value: o3).rawValue,
            AirQualityIndex.getIndex(forPollutant: "co", value: co).rawValue,
        ]
    }
    
}

enum AirQualityIndex: Int {
    case good = 1
    case fair = 2
    case moderate = 3
    case poor = 4
    case veryPoor = 5
    
    static func getIndex(forPollutant pollutant: String, value: Double) -> AirQualityIndex {
        switch pollutant {
        case "so2":
            switch value {
            case 0..<20:
                return .good
            case 20..<80:
                return .fair
            case 80..<250:
                return .moderate
            case 250..<350:
                return .poor
            default:
                return .veryPoor
            }
        case "no2":
            switch value {
            case 0..<40:
                return .good
            case 40..<70:
                return .fair
            case 70..<150:
                return .moderate
            case 150..<200:
                return .poor
            default:
                return .veryPoor
            }
        case "pm10":
            switch value {
            case 0..<20:
                return .good
            case 20..<50:
                return .fair
            case 50..<100:
                return .moderate
            case 100..<200:
                return .poor
            default:
                return .veryPoor
            }
        case "pm25":
            switch value {
            case 0..<10:
                return .good
            case 10..<25:
                return .fair
            case 25..<50:
                return .moderate
            case 50..<75:
                return .poor
            default:
                return .veryPoor
            }
        case "o3":
            switch value {
            case 0..<60:
                return .good
            case 60..<100:
                return .fair
            case 100..<140:
                return .moderate
            case 140..<180:
                return .poor
            default:
                return .veryPoor
            }
        case "co":
            switch value {
            case 0..<4400:
                return .good
            case 4400..<9400:
                return .fair
            case 9400..<12400:
                return .moderate
            case 12400..<15400:
                return .poor
            default:
                return .veryPoor
            }
            
        default:
            return .good
        }
    }
        
}
