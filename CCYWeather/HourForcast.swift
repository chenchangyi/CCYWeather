//
//  HourForcast.swift
//  CCYWeather
//
//  Created by 陈昌怡 on 15/3/16.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import Foundation
import CoreData
@objc(HourForcast)
class HourForcast: NSManagedObject {

    @NSManaged var wind_speed: NSNumber
    @NSManaged var temp: NSNumber
    @NSManaged var weather: String
    @NSManaged var icon: String
    @NSManaged var dt: NSNumber

}
