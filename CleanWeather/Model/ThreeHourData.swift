//
//  ThreeHourData.swift
//  CleanWeather
//
//  Created by Serhat Cihangir on 9.11.2023.
//

import Foundation

struct ThreeHourData: Decodable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ThreeHourDataItem]
    let city: CityInfo
    
    
    struct ThreeHourDataItem: Decodable {
        let dt: Int
        let main: ThreeHourDataDetails
        let weather: [WeatherInfo]
        let clouds: CloudsInfo
        let wind: WindInfo
        let visibility: Int
        let pop: Double?
        let snow, rain: SnowInfo?
        let sys: SysInfo
        let dtTxt: String
    }
    
    struct ThreeHourDataDetails: Decodable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let seaLevel: Int
        let groundLevel: Int?
        let humidity: Int
        let tempKf: Double
    }
    
    struct WeatherInfo: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct CloudsInfo: Decodable {
        let all: Int
    }
    
    struct WindInfo: Decodable {
        let speed: Double
        let deg: Int
        let gust: Double
    }
    
    struct SnowInfo: Decodable {
        let the3H: Double // Renamed from "3h" to "ThreeHourData"
        
        enum CodingKeys: String, CodingKey {
            case the3H = "3h"
        }
    }
    
    struct SysInfo: Decodable {
        let pod: String
    }
    
    struct CityInfo: Decodable {
        let id: Int
        let name: String
        let coord: Coordinates
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
    }
    
    struct Coordinates: Decodable {
        let lat: Double
        let lon: Double
    }
}
