//
//  AirPollutionData.swift
//  CleanWeather
//
//  Created by serhat on 26.12.2023.
//

import Foundation

// MARK: - AirPollutionData
struct AirPollutionData: Codable {
    let coord: Coord
    let list: [List]
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - List
struct List: Codable {
    let main: Main
    let components: [String: Double]
    let dt: Int
}

// MARK: - Main
struct Main: Codable {
    let aqi: Int
}
