//
//  WeatherCell.swift
//  CleanWeather
//
//  Created by serhat on 9.01.2024.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var myLocation: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempHigh: UILabel!
    @IBOutlet weak var tempLow: UILabel!
    
    static let idetifier = "WeatherCell"
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCell", bundle: nil)
    }
    let background = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBackground()
        self.selectionStyle = .none
    }
    
    public func setCell (data: WeatherModel){
        let cellData = data
        if(cellData.isCurrentLocation) {
            cityLabel.text = "Current Location"
            myLocation.text = cellData.cityName
        }else {
            cityLabel.text = cellData.cityName
            myLocation.text = ""
        }
        descriptionLabel.text = cellData.capitalizedDescription
        tempLabel.text = cellData.tempratureStr
        tempHigh.text = cellData.tempHighStr
        tempLow.text = cellData.tempLowhStr
        weatherIcon.image = UIImage(named: cellData.icon)
    }
    
    private func setupBackground() {
        self.backgroundColor = UIColor.clear
        
        contentView.insertSubview(background, at: 0)
        background.backgroundColor = UIColor(white: 1.0, alpha: 0.3) //.none// .lightGray
        background.layer.cornerRadius = 20
        background.layer.borderWidth = 2
        background.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        
        background.translatesAutoresizingMaskIntoConstraints = false
        background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        background.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }
    
}
