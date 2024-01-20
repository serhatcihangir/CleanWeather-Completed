//
//  WeatherData.swift
//  CleanWeather
//
//  Created by Serhat Cihangir on 28.10.2023.
//

import Foundation

struct WeatherData: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let timezone, id: Int
    let name: String
    let cod: Int
    
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }
    
    
    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }
    
    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int
    }
    
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }
    
    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
}
