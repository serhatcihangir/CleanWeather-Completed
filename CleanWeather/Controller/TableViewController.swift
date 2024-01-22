//
//  Table View Controller.swift
//  CleanWeather
//
//  Created by serhat on 5.01.2024.
//

import UIKit
import CoreLocation

class TableViewController: UIViewController {
    
    enum Section { case main }
    
    @IBOutlet weak var tableView: UITableView!
    
    private let defaults = UserDefaults.standard
    
    let searchController = UISearchController()
    let locationManager = CLLocationManager()
    private var apiManager = ApiManager()
    
    private var locationList: [WeatherModel] = []
    private var filteredList: [WeatherModel] = []
    private var didPerformGeocode = false
    private var selectedRow:Int = 0
    private var searchToAddNew: Bool = false
    private var dataSource: UITableViewDiffableDataSource<Section, WeatherModel>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterfaceForCurrentTraitCollection()
        
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(WeatherCell.nib(), forCellReuseIdentifier: WeatherCell.idetifier)
        self.createDataSource()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.placeholder = "City Name"
        navigationItem.searchController?.searchBar.tintColor = .white.withAlphaComponent(0.8)
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .white.withAlphaComponent(0.4)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        apiManager.tableViewDelegate = self
        
        if let cityArray = defaults.array(forKey: "List") {
            //print("Opening: ", cityArray)
            if let data = cityArray as? [String]{
                updateAllRow(cities: data)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
}

// MARK: -  willEnterForegroundNotification

extension TableViewController {
    
    @objc func appWillEnterForeground() {
        let delayInMilliseconds = 250
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
            self.didPerformGeocode = false
            self.locationManager.startUpdatingLocation()
        }
    }
}

// MARK: -  DataSource - TableView

extension TableViewController {
    
    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, WeatherModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(locationList)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func createDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.idetifier, for: indexPath) as! WeatherCell
            cell.setCell(data: model)
            return cell
        })
        dataSource.defaultRowAnimation = .left
    }
}

// MARK: - Save to Database - UserDefaults

extension TableViewController {
    
    func saveLocation(data: [WeatherModel]) {
        let cityArray = data.filter { $0.isCurrentLocation == false }.map { $0.cityName }
        self.defaults.set(cityArray, forKey: "List")
        //print("Saved: ", cityArray)
    }
}

// MARK: - Update Rows Of Tableview

extension TableViewController {
    
    func updateAllRow(cities: [String]) {

        for index in 0..<cities.count {
            let delayInMilliseconds = 200 * index
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayInMilliseconds)) {
                self.apiManager.getWeatherData(type: WeatherData.self, url: ApiManager.urlCurrentWeather , cityName: cities[index] )
            }
        }
    }
}


// MARK: - ViewController Delegates - Add City

extension TableViewController: AddCityDelegate {
    
    func addButtonClicked() {
        DispatchQueue.main.async { self.updateDataSource() }
        searchController.searchBar.text = ""
        searchController.isActive = false
    }
    
    func closeButtonClicked() {
        locationList.removeLast()
        saveLocation(data: locationList)
    }
}

// MARK: - TableView Delegates

extension TableViewController:  UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        DispatchQueue.main.async { tableView.isUserInteractionEnabled = false }
        tableView.deselectRow(at: indexPath, animated: true)
        if !filteredList.isEmpty {
            apiManager.getWeatherData(type: ThreeHourData.self, url: ApiManager.url3hourForecastWeather, cityName: filteredList[selectedRow].cityName)
        }else{
            apiManager.getWeatherData(type: ThreeHourData.self, url: ApiManager.url3hourForecastWeather, cityName: locationList[selectedRow].cityName)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
            var snapshot = self.dataSource.snapshot()
            if let item = self.dataSource.itemIdentifier(for: indexPath)  {
                if item.isCurrentLocation == false {
                    locationList.removeAll { $0.cityName == item.cityName }
                    self.saveLocation(data: locationList)
                    snapshot.deleteItems([item])
                    self.dataSource.apply(snapshot,animatingDifferences: true)
                }
            }
            completionHandler(true)
        }
        let conf = UIImage.SymbolConfiguration(paletteColors: [.systemRed])
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: conf)
        deleteAction.backgroundColor = .systemRed.withAlphaComponent(0.0)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    
    func scrollTop() {
        let topOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
        tableView.setContentOffset(topOffset, animated: true)
    }
    
}

// MARK: - ApiManager Delegate

extension TableViewController: TableViewApiManagerDelegate {
    
    func readyToGoNextVC(_ apiManager: ApiManager, weatherHourly: ThreeHourModel) {
        if searchToAddNew {
            searchToAddNew = false
            DispatchQueue.main.async { [self] in
                tableView.isUserInteractionEnabled = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    vc.weatherData = locationList.last
                    vc.hourlyDataForStepper = weatherHourly
                    vc.delegate = self
                    present(vc, animated: true)
                }
            }
        }else{
            DispatchQueue.main.async { [self] in
                tableView.isUserInteractionEnabled = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    if filteredList.isEmpty{
                        vc.weatherData = locationList[selectedRow]  //locationList.last
                    }else {
                        vc.weatherData = filteredList[selectedRow]
                    }
                    vc.hourlyDataForStepper = weatherHourly
                    vc.isHiddenFlag = true
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    func didUpdateWeather(_ apiManager: ApiManager, weather: WeatherModel) {
        if searchToAddNew {
            locationList.append(weather)
            saveLocation(data: locationList)
            self.apiManager.getWeatherData(type: ThreeHourData.self, url: ApiManager.url3hourForecastWeather, cityName: weather.cityName)
        }else{
            if weather.isCurrentLocation {
                let cLoc =  locationList.filter{$0.isCurrentLocation}
                if cLoc.isEmpty {
                    locationList.insert(weather, at: 0)
                }else{
                    locationList.remove(at: 0)
                    locationList.insert(weather, at: 0)
                }
            }else {
                locationList.append(weather)
            }
            saveLocation(data: locationList)
            DispatchQueue.main.async { self.updateDataSource() }
        }
    }
    
    func didFail(error: Error) {
        DispatchQueue.main.async {
            self.tableView.isUserInteractionEnabled = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                vc.errorHiddenFlag = true
                vc.modalPresentationStyle = .pageSheet
                vc.sheetPresentationController?.detents = [ .custom(resolver: { context in
                    return context.maximumDetentValue * 0.65
                })] //, .large()]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                vc.isModalInPresentation = false
                self.present(vc, animated: true)
            }
        }
    }
    
}

//MARK: - UISearchController

extension TableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        scrollTop()
        
        if let text = searchController.searchBar.text{
            if text.count > 0 {
                filteredList = locationList.filter { model in
                    return model.cityName.starts(with: text)
                }
                var snapshot = NSDiffableDataSourceSnapshot<Section, WeatherModel>()    //self.dataSource.snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(filteredList,toSection: .main) //toSection eklendi.
                self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
            }else{
                filteredList.removeAll()
                DispatchQueue.main.async { self.updateDataSource() }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if filteredList.isEmpty{
                searchToAddNew = true
                apiManager.getWeatherData(type: WeatherData.self, url: ApiManager.urlCurrentWeather, cityName: text)
            }
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { self.updateDataSource() }
        searchToAddNew = false
    }
    
}



//MARK: - LocationManagerDelegate

extension TableViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        guard !didPerformGeocode else { return }
        didPerformGeocode = true
        if let location = locations.last{
//            print(location.coordinate.latitude, location.coordinate.longitude)
            apiManager.getWeatherData(type: WeatherData.self, url: ApiManager.urlCurrentWeather, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}



//MARK: - Gradient Background w/ Dark Mode - UIView

extension TableViewController {
    func updateInterfaceForCurrentTraitCollection() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        if traitCollection.userInterfaceStyle == .dark {
            let topColor = UIColor(hexString: "#1c92d2").cgColor
            let middleColor = UIColor(hexString: "#416D8D").cgColor
            let bottomColor = UIColor(hexString: "#283E51").cgColor
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        } else {
            let topColor = UIColor(hexString: "#5A9ACA").cgColor
            let middleColor = UIColor(hexString: "#1c92d2").cgColor
            let bottomColor = UIColor(hexString: "#6DD5FA").cgColor
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        }
        gradientLayer.locations = [0.0, 0.70, 1.0] // Adjust the positions of colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        if let existingGradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingGradient.removeFromSuperlayer()
        }
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateInterfaceForCurrentTraitCollection()
    }
}

