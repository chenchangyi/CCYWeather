//
//  DayForcastData.swift
//  CCYWeather
//
//  Created by 陈昌怡 on 15/3/16.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import Foundation
import CoreData
@objc(DayForcast)
class DayForcast: NSManagedObject {

    @NSManaged var descrip: String
    @NSManaged var dt: NSNumber
    @NSManaged var icon: String
    @NSManaged var tempMax: NSNumber
    @NSManaged var tempMin: NSNumber

}
