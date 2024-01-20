//
//  ViewController.swift
//  CleanWeather
//
//  Created by Serhat Cihangir on 17.10.2023.
//

import UIKit
import CoreLocation

protocol AddCityDelegate {
    func closeButtonClicked()
    func addButtonClicked()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var airQualityButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var scrollView: UIScrollView!
    private var apiManager = ApiManager()
    var delegate: AddCityDelegate?
    
    var hourlyDataForStepper: ThreeHourModel?
    var weatherData: WeatherModel?
    var isHiddenFlag = false
    var errorHiddenFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.layer.cornerRadius = 10
        
        setupScrollView(numberOfItems: Int(stepper.value))
        updateInterfaceForCurrentTraitCollection()
        
        apiManager.viewControllerDelegate = self
        
        if let mainLabelData = weatherData {
            cityLabel.text = mainLabelData.cityName
            tempLabel.text = mainLabelData.tempratureStr
            descriptionLabel.text = mainLabelData.description.capitalized
            weatherIcon.image = UIImage(named: mainLabelData.icon)
        }
        if let scrollData = hourlyDataForStepper {
            updateScrollView(weatherHourly: scrollData)
        }
        cancelButton.isHidden = isHiddenFlag
        addButton.isHidden = isHiddenFlag
        
        
        if errorHiddenFlag {
            cityLabel.text = "City not found..."
            tempLabel.text = "--"
            descriptionLabel.text = ""
            weatherIcon.image = UIImage(named: "help")
            scrollView.isHidden = errorHiddenFlag
            stepper.isHidden = errorHiddenFlag
            stepperLabel.isHidden = errorHiddenFlag
            airQualityButton.isHidden = errorHiddenFlag
            
            addButton.isHidden = !isHiddenFlag
            cancelButton.isHidden = !isHiddenFlag
        }
        
    }
    
    
}

// MARK: - TextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    @IBAction func addClicked(_ sender: Any) {
        self.delegate?.addButtonClicked()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.delegate?.closeButtonClicked()
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - ApiManager Delegate

extension ViewController: ViewControllerApiManagerDelegate {
    
    func readyBottomSheetData(_ apiManager: ApiManager, bottomSheetData: AirPollutionModel) {
        
        DispatchQueue.main.sync {
            //self.performSegue(withIdentifier: "goToBottomSheet", sender: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let picker = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController") as? BottomSheetViewController {
                picker.modalPresentationStyle = .pageSheet
                picker.sheetPresentationController?.detents = [ .custom(resolver: { context in
                    return context.maximumDetentValue * 0.44
                })] //, .large()]
                picker.sheetPresentationController?.prefersGrabberVisible = true
                picker.isModalInPresentation = false
                picker.bottomSheetAqiData = bottomSheetData
                present(picker, animated: true)
            }
        }
        
    }
    
    func didFail(error: Error) {
        //print(error)
    }
    
}


//MARK: - Stepper

extension ViewController {
    @IBAction func stepperForScrollView(_ sender: UIStepper){
        stepper.isEnabled = false
        stepperLabel.text = String(Int(sender.value))
        setupScrollView(numberOfItems: Int(stepper.value))
        scrollView.isHidden = false
        
        if let weatherHourly = self.hourlyDataForStepper {
            updateScrollView(weatherHourly: weatherHourly)
        }
    }
}

//MARK: - Button-AirQualityIndex

extension ViewController {
    @IBAction func airQualityButtonClicked (_ sender: UIButton) {
        if let coord = weatherData {
            apiManager.getWeatherData(type: AirPollutionData.self, url: ApiManager.urlAirPollution, latitude: coord.lat, longitude: coord.lon)
        }
    }
}

//MARK: - Update ScrollView

extension ViewController {
    
    private func updateScrollView (weatherHourly: ThreeHourModel) {
        let newScrollView = view.subviews.last as? UIScrollView
        
        if let newScroll = newScrollView {
            let getContainer = newScroll.subviews.filter { $0.tag == 99 }
            let container = getContainer.first
            let size: Int = (container?.subviews.count)!
            for index in 0..<size {
                if let label1 = container?.subviews[index].viewWithTag(1) as? UILabel {
                    label1.text = weatherHourly.eachThreeHours[index].date
                }
                if let label2 = container?.subviews[index].viewWithTag(2) as? UILabel {
                    label2.text = weatherHourly.eachThreeHours[index].hour
                }
                if let label3 = container?.subviews[index].viewWithTag(4) as? UILabel {
                    label3.text = weatherHourly.eachThreeHours[index].temp
                }
                if let icon = container?.subviews[index].viewWithTag(3) as? UIImageView {
                    icon.image = UIImage(named: weatherHourly.eachThreeHours[index].icon)
                }
            }
            newScroll.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            newScroll.isHidden = false
            let scrollViewToRemove = self.view.subviews.filter { $0 is UIScrollView }
            if scrollViewToRemove.count == 2 {
                scrollViewToRemove.first?.removeFromSuperview()
            }
            self.stepper.isEnabled = true
        }
    }
    
}

//MARK: - Adding ScrollView Programmatically.

extension ViewController {
    
    private func setupScrollView(numberOfItems: Int) {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layer.cornerRadius = 20 // Change this value to your desired corner radius
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = UIColor(named: "background")
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 15),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.tag = 99
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        var previousView: UIView?
        
        for _ in 0..<numberOfItems {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            // Create a vertical stack view for each 'view'
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 4 // Adjust vertical spacing
            
            view.addSubview(stackView)
            
            // Label 1
            let label1 = UILabel()
            label1.translatesAutoresizingMaskIntoConstraints = false
            label1.text = ""
            label1.textAlignment = .center
            label1.font = .systemFont(ofSize: 11.0)
            label1.tag = 1
            stackView.addArrangedSubview(label1)
            
            // Label 2
            let label2 = UILabel()
            label2.translatesAutoresizingMaskIntoConstraints = false
            label2.text = ""
            label2.textAlignment = .center
            label2.font = .systemFont(ofSize: 18.0)
            label2.tag = 2
            stackView.addArrangedSubview(label2)
            
            // Inside the loop where you create the image view
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            //imageView.image = UIImage(named: "04d")
            imageView.contentMode = .scaleAspectFit // Set content mode to scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: 33).isActive = true // Set height to 33
            imageView.tag = 3
            stackView.addArrangedSubview(imageView)
            
            
            // Label 3
            let label3 = UILabel()
            label3.translatesAutoresizingMaskIntoConstraints = false
            label3.text = ""
            label3.textAlignment = .center
            label3.font = .systemFont(ofSize: 18.0)
            label3.tag = 4
            stackView.addArrangedSubview(label3)
            
            
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -13) //(equalTo: view.bottomAnchor)
            ])
            
            
            NSLayoutConstraint.activate([
                //widthAnchor.constraint(equalTo: scrollView.heightAnchor),
                view.widthAnchor.constraint(equalToConstant: 120),
                view.heightAnchor.constraint(equalTo: contentView.heightAnchor),
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            if let previousView = previousView {
                view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true //constant kalkabilir constant: 5
            } else {
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            }
            
            previousView = view
        }
        
        if let lastView = previousView {
            lastView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        }
        
    }
}


//MARK: - Gradient Background w/ Dark Mode - UIView

extension ViewController {
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
            let middleColor = UIColor(hexString: "#6DD5FA").cgColor
            let bottomColor = UIColor(hexString: "#FFFFFF").cgColor
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

//MARK: - UIColor Hex String

extension UIColor {
    convenience init(hexString: String) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
