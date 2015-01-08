//
//  WeatherTracker.swift
//  BitWatch
//
//  Created by Phuoc Dai Le on 1/8/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation

public typealias TempRequestCompletionBlock = (temp: NSNumber?, error: NSError?) -> ()

public class WeatherTracker {
    let defaults = NSUserDefaults.standardUserDefaults()
    let session: NSURLSession
    let URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=35.6710508&lon=139.756391&mode=json&cnt=1"
    
    
    public init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: configuration);
    }
    
    public class var tempFormatter: NSNumberFormatter {
        struct TempFormatter {
            static var token: dispatch_once_t = 0
            static var instance: NSNumberFormatter? = nil
        }
        dispatch_once(&TempFormatter.token) {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            TempFormatter.instance = formatter
        }
        return TempFormatter.instance!
    }
    
    public func requestTemp(completion: TempRequestCompletionBlock) {
        let request = NSURLRequest(URL: NSURL(string: URL)!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error == nil {
                var JSONError: NSError?
                let responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &JSONError) as NSDictionary
                if JSONError == nil {
                    let list: NSArray = responseDict["list"] as NSArray
                    let today: NSDictionary = list.firstObject as NSDictionary
                    let temp: NSDictionary = today["temp"] as NSDictionary
                    var max: NSNumber = temp["max"] as NSNumber
                    
                    self.defaults.setObject(max, forKey: "max")
                    self.defaults.setObject(NSDate(), forKey: "date")
                    self.defaults.synchronize()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(temp: max, error: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(temp: nil, error: JSONError)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(temp: nil, error: error)
                })
            }
        })
        task.resume()
    }
}
