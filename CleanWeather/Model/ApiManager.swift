//
//  ApiManager.swift
//  CleanWeather
//
//  Created by Serhat Cihangir on 25.10.2023.
//

import Foundation
import CoreLocation

protocol TableViewApiManagerDelegate {
    func didUpdateWeather(_ apiManager: ApiManager, weather: WeatherModel)
    func readyToGoNextVC(_ apiManager: ApiManager, weatherHourly: ThreeHourModel)
    func didFail( error: Error)
}

protocol ViewControllerApiManagerDelegate {
    func readyBottomSheetData(_ apiManager: ApiManager, bottomSheetData: AirPollutionModel)
    func didFail( error: Error)
}

struct ApiManager {
    
    private let apiKey = "4a8b999f667ba0e7a4017c049dfbd8b8"
    var tableViewDelegate: TableViewApiManagerDelegate?
    var viewControllerDelegate: ViewControllerApiManagerDelegate?
    
    static let urlCurrentWeather = "https://api.openweathermap.org/data/2.5/weather"
    static let url3hourForecastWeather = "https://api.openweathermap.org/data/2.5/forecast"
    static let urlAirPollution = "https://api.openweathermap.org/data/2.5/air_pollution?"
    
    mutating func getWeatherData<T: Decodable>(type: T.Type, url: String, cityName: String) {
        var url = URLComponents(string: url)!
        let queryItems = [URLQueryItem(name: "q", value: cityName ), URLQueryItem(name: "units", value: "metric"), URLQueryItem(name: "appid", value: apiKey),URLQueryItem(name: "cnt", value: String(20))]
        url.queryItems = queryItems
        //url.queryItems?.append( URLQueryItem(name: "cnt", value: String(8)) )
        apiRequest(type:type, with: url)
    }
    
    mutating func getWeatherData<T: Decodable>(type: T.Type, url: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        var url = URLComponents(string: url)!
        let queryItems = [ URLQueryItem(name: "lat", value: String(latitude) ), URLQueryItem(name: "lon", value: String(longitude) ), URLQueryItem(name: "units", value: "metric"), URLQueryItem(name: "appid", value: apiKey),URLQueryItem(name: "cnt", value: String(20)) ]
        url.queryItems = queryItems
        apiRequest(type:type, with: url)
    }
    
    
    func apiRequest<T: Decodable>(type: T.Type, with url: URLComponents) {
        if let urlRequest = url.url {
            //url.de lat lon varsa current Location.dır
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlRequest) { data, response, error in
                if error != nil {
                    print("Error apiRequest")
                    type == AirPollutionData.self ? viewControllerDelegate?.didFail(error: error!) : tableViewDelegate?.didFail(error: error!)
                    return
                }
                if let response = data {
                    
                    if(type == WeatherData.self){
                        if let weather = self.jsonParse(type: WeatherData.self, weatherData: response) {
                            var weatherModel = WeatherModel(from: weather)
                            if url.string!.contains("lon") && url.string!.contains("lat") {
                                weatherModel.isCurrentLocation = true
                            }
                            self.tableViewDelegate?.didUpdateWeather(self, weather: weatherModel)
                        }
                    }else if(type == ThreeHourData.self){
                        if let weather = self.jsonParse(type: ThreeHourData.self, weatherData: response) {
                            let hourlyModel = ThreeHourModel(from: weather)
                            self.tableViewDelegate?.readyToGoNextVC(self, weatherHourly: hourlyModel)
                            //print(hourlyModel)
                        }
                    }else if(type == AirPollutionData.self){
                        if let airPollıtionResponse = self.jsonParse(type: AirPollutionData.self, weatherData: response) {
                            let airPollution = AirPollutionModel(from: airPollıtionResponse)
                            self.viewControllerDelegate?.readyBottomSheetData(self, bottomSheetData: airPollution)
                            //print(airPollution)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    private func jsonParse<T: Decodable>(type: T.Type, weatherData: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedData = try decoder.decode(T.self, from: weatherData)
            return decodedData
        } catch {
            //print("Error jsonParse", T.self, error.localizedDescription)
            type == AirPollutionData.self ? viewControllerDelegate?.didFail(error: error) : tableViewDelegate?.didFail(error: error)
            return nil
        }
    }

}
