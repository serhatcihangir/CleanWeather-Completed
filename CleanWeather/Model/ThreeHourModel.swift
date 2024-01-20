//
//  ThreeHourModel.swift
//  CleanWeather
//
//  Created by serhat on 22.11.2023.
//

import Foundation

struct ThreeHourModel: Codable {
    

    let eachThreeHours: [EachThreeHourInfo]
    
    struct EachThreeHourInfo: Codable {
        let date: String
        let hour: String
        let icon: String
        let temp: String
    }

    init(from source: ThreeHourData) {
        var tmp: [EachThreeHourInfo] = [] // Initialize the array
        for item in source.list {
            let timestamp = TimeInterval(item.dt)
            let date = Date(timeIntervalSince1970: timestamp)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: date)
            
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH"
            let hourString = hourFormatter.string(from: date)
            
            let tempratureStr = String(format: "%.1f", item.main.temp) + " °C"
            
            let data = EachThreeHourInfo(date: dateString,
                                         hour: hourString,
                                         icon: item.weather[0].icon,
                                         temp: tempratureStr)
            tmp.append(data) // Append data to the temporary array
        }
        eachThreeHours = tmp // Assign the temporary array to the property
    }

    init(eachThreeHours: [EachThreeHourInfo]) {
        self.eachThreeHours = eachThreeHours
    }

}
