# ![github](https://github.com/serhatcihangir/CleanWeather/blob/main/readmeIMGs/weather-app32.png) CleanWeather: Your Comprehensive iOS Weather App

## Introduction

CleanWeather is an iOS weather app that provides a comprehensive way to check the weather. It utilizes the OpenWeather API to fetch real-time weather data and offers a clean and user-friendly interface. The app has undergone significant enhancements with the addition of new features and improvements.

<div align="center">
  <img src="https://github.com/serhatcihangir/CleanWeather-Completed/blob/main/screenshots/CleanWeather-ScreenGif.gif" width="265" alt="CleanWeather App Screen">
</div>



## New Features

- **TableView Integration**: CleanWeather now incorporates a table view, allowing users to manage their saved cities. Users can add and remove cities directly from the table view interface.

- **UITableViewDiffableDataSource**: The table view implementation utilizes `UITableViewDiffableDataSource` as its data source. This provides a visually appealing way to handle search, addition, and deletion of cities.

- **Generic Functions**: A generic function has been introduced in the APIManager code as an example of generics usage. For instance, `jsonParse<T: Decodable>(type: T.Type, weatherData: Data) -> T?` demonstrates the utilization of generics within the application.
  ```swift
    private func jsonParse<T: Decodable>(type: T.Type, weatherData: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedData = try decoder.decode(T.self, from: weatherData)
            return decodedData
        } catch {
            type == AirPollutionData.self ? viewControllerDelegate?.didFail(error: error) : tableViewDelegate?.didFail(error: error)
            return nil
        }
    }
  ```

- **ScrollView - Hourly Weather Forecast**: Users can now access hourly weather forecasts through the app. This information is presented using a horizontal scroll view, allowing users to visualize weather conditions for the upcoming hours. Additionally, a stepper component enables users to dynamically update the displayed data.

- **Air Quality Index**: CleanWeather now provides information on the air quality index of city. This data is displayed to the user via a bottom sheet, offering insights into air quality conditions.

- **Air Quality Index Visualization**: The air quality index information is visualized within the bottom sheet using a bar graph. The DGCharts library, integrated via Swift Package Manager, facilitates the creation of visually appealing and informative graphs.

## Design Patterns and Technologies

### MVC (Model-View-Controller)

CleanWeather continues to adhere to the Model-View-Controller design pattern for organized code architecture.

### Delegate Design Pattern with Protocols

The app utilizes the Delegate design pattern along with protocols to ensure efficient data communication and separation of concerns.

## Dependencies

- **OpenWeather RESTful API (Free Subscription)**: CleanWeather relies on the OpenWeather API to fetch weather data. Users are required to obtain an API key from OpenWeather and integrate it into the project.

- **DGCharts**: The DGCharts library, added via Swift Package Manager, is utilized for visualizing the air quality index data in the form of bar graphs.

## Getting Started

To run CleanWeather on your local machine:

1. Clone the repository: `git clone https://github.com/serhatcihangir/CleanWeather-Completed.git`
2. Open the Xcode project.
3. Ensure you have obtained an API key from OpenWeather and added it to the project to fetch weather data. (Refer to `CleanWeather/Model/ApiManager.swift`)
4. Build and run the app on your iOS device or simulator.

## How to Contribute

Contributions to CleanWeather from the open-source community are welcome! Whether it's reporting a bug, suggesting a feature, or submitting a pull request, your involvement is appreciated. To contribute:

1. Fork the repository.
2. Create a new branch (e.g., `feature/new-feature`).
3. Commit your changes.
4. Push to your branch.
5. Create a Pull Request.
