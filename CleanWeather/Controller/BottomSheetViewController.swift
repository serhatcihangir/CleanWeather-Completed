//
//  BottomSheetViewController.swift
//  CleanWeather
//
//  Created by serhat on 26.12.2023.
//

import UIKit
import DGCharts

class BottomSheetViewController: UIViewController {

    var bottomSheetAqiData: AirPollutionModel?
    var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInterfaceForCurrentTraitCollection()
        createBarChart()
        
    }
    
    private func createBarChart() {
        guard let aqiData = bottomSheetAqiData else {
            return
        }
        
        let barChart = BarChartView()
        barChart.rightAxis.enabled = false
        barChart.xAxis.axisLineWidth = 1.0
        barChart.xAxis.axisLineColor = .black
        barChart.xAxis.labelPosition = .bottom
        barChart.leftAxis.axisLineWidth = 1.0
        barChart.leftAxis.axisLineColor = .black
        barChart.leftAxis.axisMinimum = 0.0 // Minimum value on the y-axis
        barChart.leftAxis.axisMaximum = 5.5 // Maximum value on the y-axis
        barChart.leftAxis.granularity = 1.0 // Interval between labels
        barChart.xAxis.gridLineWidth = 0.0
        barChart.legend.enabled = false
        barChart.animate(yAxisDuration: 1)
        
        if let labelFont = UIFont(name: "PingFangTC-Regular", size: 14.0) {
            barChart.leftAxis.labelFont = labelFont
            barChart.leftAxis.labelTextColor = .black
        }
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["SO2", "NO2", "PM10", "PM2_5", "O3", "CO"])
        if let labelFont = UIFont(name: "PingFangTC-Regular", size: 11.0) {
            barChart.xAxis.labelFont = labelFont
            barChart.xAxis.labelTextColor = .black
        }

        //so2 no2 pm10 pm25 o3 co
        var entries = [BarChartDataEntry]()
        for x in 0..<6 {
            entries.append(BarChartDataEntry(x: Double(x),
                                             y: Double((aqiData.indexsArray[x]))
                                            )
            )
        }
        let set = BarChartDataSet(entries: entries)
        set.valueFont = UIFont(name: "PingFangTC-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 14.0)
        set.colors = ChartColorTemplates.colorful()
        let data = BarChartData(dataSet: set)
        barChart.data = data
        
        let aqiLabel = UILabel()
        aqiLabel.translatesAutoresizingMaskIntoConstraints = false
        aqiLabel.text = "Air Quality Index: " + aqiData.aqi
        aqiLabel.font = UIFont(name: "PingFangTC-Regular", size: 25.0) ?? UIFont.systemFont(ofSize: 14.0)
        aqiLabel.textAlignment = .center
        
        // Create a vertical stack view for each 'view'
        let stackView = UIStackView(arrangedSubviews: [barChart, aqiLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15 // Adjust vertical spacing
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50) 
        ])
        
    }
    
}

//MARK: - Gradient Background w/ Dark Mode - UIView

extension BottomSheetViewController {
    func updateInterfaceForCurrentTraitCollection() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        if traitCollection.userInterfaceStyle == .dark {
            let topColor = UIColor(hexString: "#1c92d2").cgColor
            let middleColor = UIColor(hexString: "#416D8D").cgColor
            let bottomColor = UIColor(hexString: "#283E51").cgColor
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        } else {
            let topColor = UIColor(hexString: "#FFFFFF").cgColor
            let middleColor = UIColor(hexString: "#6DD5FA").cgColor
            let bottomColor = UIColor(hexString: "#5A9ACA").cgColor
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        }
        gradientLayer.locations = [0.0, 0.35, 1.0] // Adjust the positions of colors
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

