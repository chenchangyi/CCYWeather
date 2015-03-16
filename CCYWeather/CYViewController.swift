 //
//  CYViewController.swift
//  CCYWeather
//
//  Created by chenchangyi on 15/3/2.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


class CYViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    //定位
    let locationManager:CLLocationManager = CLLocationManager()
    let weatherService = WeatherService()

    
    var backgroundImageView:UIImageView!
    var blurredImageView:UIImageView!
    var tableView:UITableView!
    var screenHeight:CGFloat!
    var cityLabel:UILabel!
    var temperatureLabel:UILabel!
    var iconView:UIImageView!
    var conditionsLabel:UILabel!
    var hiloLabel:UILabel!

    lazy var currentWeather:CurrentWeather = {
        let request = NSFetchRequest(entityName: "CurrentWeather")
        let currentWeather = AppDelegate.cdh.context.executeFetchRequest(request, error: nil)?.first as CurrentWeather
        return currentWeather
    }()
    
    lazy var hourForcast:[HourForcast] = {
        let request = NSFetchRequest(entityName: "HourForcast")
        let sort = NSSortDescriptor(key: "dt", ascending: true)
        request.sortDescriptors = [sort]
        let hourforcast = AppDelegate.cdh.context.executeFetchRequest(request, error: nil) as [HourForcast]
        return hourforcast
    }()
    
    lazy var dayForcast:[DayForcast] = {
        let request = NSFetchRequest(entityName: "DayForcast")
        let sort = NSSortDescriptor(key: "dt", ascending: true)
        request.sortDescriptors = [sort]
        let data = AppDelegate.cdh.context.executeFetchRequest(request, error: nil) as [DayForcast]
        return data
        }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.loadSubViews()
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        locationManager.startUpdatingLocation()
    }
    
    //MARK: loadSubView
    func loadSubViews(){
        //1
        self.screenHeight = UIScreen.mainScreen().bounds.size.height
        let background = UIImage(named: "bg")
        //2
        self.backgroundImageView = UIImageView(image: background)
        self.backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(self.backgroundImageView)
        //3
        self.blurredImageView = UIImageView()
        self.blurredImageView.contentMode = .ScaleAspectFill
        self.blurredImageView.alpha = 0
        self.blurredImageView.setImageToBlur(background, blurRadius: 10, completionBlock: nil)
        self.view.addSubview(self.blurredImageView)
        //4
        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.2)
        self.tableView.pagingEnabled = true
        self.view.addSubview(self.tableView)
        
        let headerFrame = UIScreen.mainScreen().bounds
        let inset:CGFloat = 20
        let temperatureHeight:CGFloat = 110
        let hiloHeight:CGFloat = 40
        let iconHeight:CGFloat = 60
        
        let hiloFrame = CGRectMake(inset,
            headerFrame.size.height - hiloHeight ,
            headerFrame.size.width - (2 * inset) ,
            hiloHeight)
        
        let temperatureFrame = CGRectMake(inset,
            headerFrame.size.height - (temperatureHeight + hiloHeight),
            headerFrame.size.width - (2 * inset),
            temperatureHeight )
        
        let iconFrame = CGRectMake(inset,
            temperatureFrame.origin.y - iconHeight,
            iconHeight,
            iconHeight)
        var conditionsFrame = iconFrame
        conditionsFrame.size.width = self.view.bounds.size.width -  (((2 * inset) + iconHeight) + 10)
        conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10)
        
        let header = UIView(frame: headerFrame)
        header.backgroundColor = UIColor.clearColor()
        self.tableView.tableHeaderView = header
        
        //bottom left
        temperatureLabel = UILabel(frame: temperatureFrame)
        temperatureLabel.backgroundColor = UIColor.clearColor()
        temperatureLabel.textColor = UIColor.whiteColor()
        temperatureLabel.text = "0°"
        temperatureLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 100)
        header.addSubview(temperatureLabel)
        
        //buttom left
        hiloLabel = UILabel(frame: hiloFrame)
        hiloLabel.backgroundColor = UIColor.clearColor()
        hiloLabel.textColor = UIColor.whiteColor()
        hiloLabel.text = "0° / 0°"
        hiloLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 28)
        header.addSubview(hiloLabel)
        
        //top
        cityLabel = UILabel(frame: CGRectMake(0, 20, self.view.bounds.size.width, 30))
        cityLabel.backgroundColor = UIColor.clearColor()
        cityLabel.textColor = UIColor.whiteColor()
        cityLabel.text = "Loading..."
        cityLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        cityLabel.textAlignment = .Center
        header.addSubview(cityLabel)
        
        conditionsLabel = UILabel(frame: conditionsFrame)
        conditionsLabel.backgroundColor = UIColor.clearColor()
        conditionsLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 25)
        conditionsLabel.textColor = UIColor.whiteColor()
        conditionsLabel.text = "sky is clear"
        header.addSubview(conditionsLabel)
        
        //bottom left
        
        iconView = UIImageView(frame: iconFrame)
        iconView.contentMode = .ScaleAspectFit
        iconView.backgroundColor = UIColor.clearColor()
        header.addSubview(iconView)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadHeaderViewData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        self.backgroundImageView.frame = bounds
        self.blurredImageView.frame = bounds
        self.tableView.frame = bounds
    }
    
    //MARK: tableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.hourForcast.count + 1
        }
        
        return self.dayForcast.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        }
        
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.imageView?.image = nil
        
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor(white: 0, alpha: 0.2)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        //
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Hourly Forecast"
            } else {
                self.reloadTableViewSection1Data(cell, indexPath: indexPath)
            }
            
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Daily Forecast"
            } else {
                self.reloadTableViewSection2Data(cell, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    //MARK: tableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        return self.screenHeight / CGFloat(cellCount)
    }
    
    //MARK: scrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //1
        let height = scrollView.bounds.size.height
        let position = max(scrollView.contentOffset.y, 0.0)
        //2
        let percent = min(position / height, 1.0)
        self.blurredImageView.alpha = percent
    }
    
    //MARK: CLLocationManagerDelegate 
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            println("lat:\(location.coordinate.latitude),lon:\(location.coordinate.longitude)")
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
         println("Can't get your location!")
    }
    // MARK:updateWeatherInfo
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //获取当前天气情况
        self.weatherService.retrieveForecast(.CurrentWeatherData, language:.ChineseSimplified,latitude: latitude, longitude: longitude, success: { (response) -> () in
            
            if let json = response.object {
                let current:CurrentWeatherData = CurrentWeatherData(json: json)
                self.currentWeather.cityName = current.cityName!
                self.currentWeather.decrip = current.description!
                self.currentWeather.humidity = current.humidity!
                self.currentWeather.icon = current.icon!
                self.currentWeather.main = current.main!
                self.currentWeather.pressure = current.pressure!
                self.currentWeather.sunrise = current.sunrise!
                self.currentWeather.sunset = current.sunset!
                self.currentWeather.temp = current.temp!
                self.currentWeather.tempMax = current.temp_max!
                self.currentWeather.tempMin = current.temp_min!
                self.currentWeather.weatherID = current.weatherID!
                self.currentWeather.windSpeed = current.wind_speed!
//                NSLog("%@", self.currentWeather)
                AppDelegate.cdh.saveContext()
                self.reloadHeaderViewData()
            }
            }) { (response) -> () in
            //error
        }
        //每三小时预报
        self.weatherService.retrieveForecast(.ThreeHourForeCast, language: .ChineseSimplified, latitude: latitude, longitude: longitude, success: { (response) -> () in
            if let json = response.object {
                let count = self.hourForcast.count
                let data:ThreeHourForcast7 = ThreeHourForcast7(json: json, count: count)
                for i in 0..<count {
                    let hourData:HourData = data.threeHourData[i]
                    self.hourForcast[i].temp = hourData.temp!
                    self.hourForcast[i].dt = hourData.dt!
                    self.hourForcast[i].weather = hourData.weather!
                    self.hourForcast[i].icon = hourData.icon!
                    self.hourForcast[i].wind_speed = hourData.wind_speed!
                }
                AppDelegate.cdh.saveContext()
                self.tableView.reloadData()
            }
            }) { (response) -> () in
            //error
        }
        //每日预报
        self.weatherService.retrieveForecast(.DayForecast, language: Language.ChineseSimplified, latitude: latitude, longitude: longitude, success: { (response) -> () in
            if let json = response.object {
                let sevenDaysForcast:SevenDaysForcast = SevenDaysForcast(json: json)
                for i in 0..<sevenDaysForcast.cnt {
                    let dayData:DayForcastData = sevenDaysForcast.dayForcastData[i]
                    self.dayForcast[i].dt = dayData.dt!
                    self.dayForcast[i].descrip = dayData.description!
                    self.dayForcast[i].tempMin = dayData.tempMin!
                    self.dayForcast[i].tempMax = dayData.tempMax!
                    self.dayForcast[i].icon = dayData.icon!
                }
                AppDelegate.cdh.saveContext()
                self.tableView.reloadData()
            }
            }) { (response) -> () in
            
        }
    }
    
    
    //MARK: reloadHeaderViewData
    func reloadHeaderViewData(){
        self.cityLabel.text = self.currentWeather.cityName
        self.conditionsLabel.text = self.currentWeather.decrip
        let temp = self.weatherService.convertTemperature(self.currentWeather.country, temperature: Double(self.currentWeather.temp))
        self.temperatureLabel.text = "\(temp)°"
        let tempMin = self.weatherService.convertTemperature(self.currentWeather.country, temperature: Double(self.currentWeather.tempMin))
        let tempMax = self.weatherService.convertTemperature(self.currentWeather.country, temperature: Double(self.currentWeather.tempMax))
        self.hiloLabel.text = "\(tempMin)°/\(tempMax)°"
        let imageName = self.currentWeather.icon
        self.iconView.image = UIImage(named: imageName)
    }
    
    //MARK: reloadTableViewData
    func reloadTableViewSection1Data(cell:UITableViewCell,indexPath:NSIndexPath){

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let date = NSDate(timeIntervalSince1970: Double(self.hourForcast[indexPath.row - 1].dt))
            let forcastTime = dateFormatter.stringFromDate(date)
            cell.textLabel?.text = forcastTime
            cell.imageView?.image = UIImage(named:self.hourForcast[indexPath.row - 1].icon)
            let tempK = self.hourForcast[indexPath.row - 1].temp as Double
            let tempC = self.weatherService.convertTemperature(self.currentWeather.country, temperature:tempK )
            cell.detailTextLabel?.text = "\(tempC)°"
    }
    
    func reloadTableViewSection2Data(cell:UITableViewCell,indexPath:NSIndexPath) {
       
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd"
            let date = NSDate(timeIntervalSince1970: Double(self.dayForcast[indexPath.row - 1].dt))
            let forcastTime = dateFormatter.stringFromDate(date)
            cell.textLabel?.text = forcastTime
//            cell.imageView?.image = UIImage(named: self.dayForcast[indexPath.row - 1].icon)

            let tempMinK = self.dayForcast[indexPath.row - 1].tempMin as Double
            let tempMInC = self.weatherService.convertTemperature(self.currentWeather.country, temperature: tempMinK)
            let tempMaxK = self.dayForcast[indexPath.row - 1].tempMax as Double
            let tempMaxC = self.weatherService.convertTemperature(self.currentWeather.country, temperature: tempMaxK)
            cell.detailTextLabel?.text = "\(tempMInC)/\(tempMaxC)°"

    }

}


