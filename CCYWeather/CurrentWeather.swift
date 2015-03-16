//
//  CurrentWeather.swift
//  CCYWeather
//
//  Created by 陈昌怡 on 15/3/15.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import Foundation
import CoreData
@objc(CurrentWeather)
class CurrentWeather: NSManagedObject {

    @NSManaged var cityName: String
    @NSManaged var country: String
    @NSManaged var decrip: String
    @NSManaged var humidity: NSNumber
    @NSManaged var icon: String
    @NSManaged var main: String
    @NSManaged var pressure: NSNumber
    @NSManaged var sunrise: NSNumber
    @NSManaged var sunset: NSNumber
    @NSManaged var temp: NSNumber
    @NSManaged var tempMax: NSNumber
    @NSManaged var tempMin: NSNumber
    @NSManaged var weatherID: NSNumber
    @NSManaged var windSpeed: NSNumber

}
