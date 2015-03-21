//
//  WeatherService.swift
//  Swift Weather Service
//
//  Created by chenchangyi on 15/3/2.
//  Copyright (c) 2015年 chenchangyi. All rights reserved.
//

import Foundation
import CoreLocation
//import SwiftyJSON
import Alamofire

public enum QueryModel {
    case CurrentWeatherData
    case ThreeHourForeCast
    case DayForecast
}

public enum Status {
    case success
    case failure
}

public enum Language {
    case English
    case Russian
    case Italian
    case Spanish
    case German
    case ChineseTraditional
    case ChineseSimplified
}

public class Response {
    public var status: Status = .failure
    public var object: JSON? = nil
    public var error: NSError? = nil
}

public struct SevenDaysForcast {
    var cnt:Int = 0
    var dayForcastData:[DayForcastData] = []
    
    init(json:JSON){
        self.cnt = json["cnt"].int! - 1
            for i in 1...cnt {
                var data:DayForcastData = DayForcastData()
                data.dt = json["list"][i]["dt"].doubleValue
                data.tempMin = json["list"][i]["temp"]["min"].doubleValue
                data.tempMax = json["list"][i]["temp"]["max"].doubleValue
                data.icon = json["list"][i]["weather"]["icon"].stringValue
                data.description = json["list"][i]["weather"]["description"].stringValue
                self.dayForcastData.append(data)
        }
    }
}

public struct DayForcastData {
    
    var dt:Double?
    var tempMax:Double?
    var tempMin:Double?
    var description:String?
    var icon:String?
    init(){}
}

public struct HourData {
    var dt:Double?//预报时间
    var wind_speed:Double?//风速
    var temp:Double?//温度
    var weather:String?//天气
    var icon:String?//天气图标
    init(){}
}

public struct ThreeHourForcast7 {
    var threeHourData:[HourData] = []
    var count:Int = 0
    init(json:JSON,count:Int){
        self.count = count

         for i in 1...self.count {

            var hourData = HourData()
            hourData.dt = json["list"][i]["dt"].doubleValue
            hourData.wind_speed = json["list"][i]["wind"]["speed"].doubleValue
            hourData.temp = json["list"][i]["main"]["temp"].doubleValue
            hourData.weather = json["list"][i]["weather"][0]["description"].stringValue
            hourData.icon = json["list"][i]["weather"][0]["icon"].stringValue
            self.threeHourData.append(hourData)
        }
    }
}


public struct CurrentWeatherData {
    var wind_speed:Double?
    var weatherID:Int?
    var description:String?
    var main:String?
    var icon:String?
    var country:String?
    var sunrise:Double?
    var sunset:Double?
    var temp:Double?
    var humidity:Int?
    var pressure:Int?
    var temp_min:Double?
    var temp_max:Double?
    var cityName:String?
    
    init(json:JSON!){
        if let sys = json["sys"].dictionaryObject {
            self.country = sys["country"] as? String//国家代码
            self.sunrise = sys["sunrise"] as? Double//日出
            self.sunset = sys["sunset"] as? Double//日落
        }
        //    "weather":[{"id":804,"main":"clouds","description":"overcast clouds","icon":"04n"}],
        if let weather = json["weather"][0].dictionaryObject {
            self.weatherID = weather["id"] as? Int//天气id
            self.main = weather["main"] as? String//主要天气
            self.description = weather["description"] as? String//天气描述
            self.icon = weather["icon"] as? String//天气图标
        }
        //    "main":{"temp":289.5,"humidity":89,"pressure":1013,"temp_min":287.04,"temp_max":292.04},
        if let main = json["main"].dictionaryObject {
            self.temp = main["temp"] as? Double//当前温度
            self.humidity = main["humidity"] as? Int//湿度
            self.pressure = main["pressure"] as? Int//气压
            self.temp_min = main["temp_min"] as? Double//最低温度
            self.temp_max = main["temp_max"] as? Double//最高温度
        }
        //    "wind":{"speed":7.31,"deg":187.002},
        if let wind = json["wind"].dictionaryObject {
            self.wind_speed = wind["speed"] as? Double
        }
        //    "name":"Shuzenji",
        self.cityName = json["name"].stringValue
    }
}

public class WeatherService {
    
    let rootUrl = "http://api.openweathermap.org/data/2.5/"
    
    public func retrieveForecast(model:QueryModel,language:Language,latitude: CLLocationDegrees, longitude: CLLocationDegrees, success:(response:Response )->(), failure: (response:Response)->()){
        var url = ""
        let language = self.outputLanguage(language)
        var params:[String:AnyObject]?
        switch model {
            case .CurrentWeatherData:
                url = "\(rootUrl)weather"
                params = ["lat":latitude, "lon":longitude,"lang":language]
            case .ThreeHourForeCast:
                url = "\(rootUrl)forecast"

                params = ["lat":latitude, "lon":longitude,"lang":language]
            case .DayForecast:
                url = "\(rootUrl)forecast/daily"

                params = ["lat":latitude, "lon":longitude,"cnt":8,"mode":"json","lang":language]
            }
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    println("Error: \(error)")
                    println(request)
                    println(response)
                    var response = Response()
                    response.status = .failure
                    response.error = error
                    failure(response: response)
                }
                else {
                    println("Success: \(url)")
                    if json != nil {
                    var json = JSON(json!)
                    var response = Response()
                    response.status = .success
                    response.object = json
                    success(response: response)
                    }
                    else {
                        println("json is \(json).")
                    }
                    
                }
        }
    }
    
    private func outputLanguage(language:Language) ->String{
        var lang = "en"
        switch language {
        case .English:
            lang = "en"
        case .Russian:
            lang = "ru"
        case .Italian:
            lang = "it"
        case .Spanish:
            lang = "sp"
        case .ChineseSimplified:
            lang = "zh_cn"
        case .ChineseTraditional:
            lang = "zh_tw"
        case .German:
            lang = "de"
        }
        return lang
    }
    
    public func convertTemperature(country: String, temperature: Double)->Double{
        if (country == "US") {
            // Convert temperature to Fahrenheit if user is within the US
            return round(((temperature - 273.15) * 1.8) + 32)
        }
        else {
            // Otherwise, convert temperature to Celsius
            return round(temperature - 273.15)
        }
    }
    
    public func isNightTime(sunrise: Double,sunset:Double)->Bool {
        let systemTime = NSDate(timeIntervalSinceNow: 0)
        let unixDate = Double(systemTime.timeIntervalSince1970)
        if unixDate > sunrise && unixDate < sunset {
            return false
        }
        return true
    }
}
