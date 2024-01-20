//
//  WeatherModel.swift
//  CleanWeather
//
//  Created by Serhat Cihangir on 28.10.2023.
//

import Foundation


struct WeatherModel: Hashable {
    let cityName: String
    let temprature: Double
    let description: String
    let icon: String
    let lat: Double
    let lon: Double
    let tempHigh: Double
    let tempLow: Double
    var isCurrentLocation: Bool = false
        
    var tempratureStr: String {
        return String(format: "%.1f°", temprature)
    }
    var tempHighStr: String {
        return String(format: "H: %.f°", tempHigh)
    }
    var tempLowhStr: String {
        return String(format: "L: %.f°", tempLow)
    }
    var capitalizedDescription: String {
        return capitalizeFirstLetterOfEachWord(description)
    }
    
    init(from source: WeatherData){
        cityName = source.name
        temprature = source.main.temp
        description = source.weather[0].description
        icon = source.weather[0].icon
        lat = source.coord.lat
        lon = source.coord.lon
        tempHigh = source.main.tempMax
        tempLow = source.main.tempMin
    }
    
    init(cityName: String, temprature: Double, description: String, icon: String, lat: Double, lon:Double, tempHigh: Double, tempLow:Double ) {
        self.cityName = cityName
        self.temprature = temprature
        self.description = description
        self.icon = icon
        self.lat = lat
        self.lon = lon
        self.tempHigh = tempHigh
        self.tempLow = tempLow
    }
    
    
    func capitalizeFirstLetterOfEachWord(_ input: String) -> String {
        let capitalizedWords = input
            .components(separatedBy: " ")
            .map { $0.prefix(1).capitalized + $0.dropFirst() }
            .joined(separator: " ")
        
        return capitalizedWords
    }
}
