//
//  InterfaceController.swift
//  BitWatch WatchKit Extension
//
//  Created by Phuoc Dai Le on 1/8/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import BitWatchKit


class InterfaceController: WKInterfaceController {
    let tracker = Tracker()
    let weatherTracker = WeatherTracker()
    var updating = false
    
    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var lastUpdatedLabel: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!

    
    @IBAction func refreshTapped() {
        update()
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        image.setHidden(true)
        updatePrice(tracker.cachedPrice())
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        update()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    private func updatePrice(price: NSNumber) {
        var temp = Double(price)
        temp -= 273.15
        priceLabel.setText(WeatherTracker.tempFormatter.stringFromNumber(NSNumber(double: temp)))
    }
    private func update() {
        if !updating {
            updating = true
            let originalPrice = tracker.cachedPrice()
            weatherTracker.requestTemp { (temp, error) -> () in
                if error == nil {
                    self.updatePrice(temp!)
                    self.updateDate(NSDate())
                    self.updateImage(originalPrice, newPrice: temp!)
                }
                self.updating = false
            }
//            tracker.requestPrice { (price, error) -> () in
//                if error == nil {
//                    self.updatePrice(price!)
//                    self.updateDate(NSDate())
//                    self.updateImage(originalPrice, newPrice: price!)
//                }
//                self.updating = false
//            }
        }
    }
    private func updateDate(date: NSDate) {
        self.lastUpdatedLabel.setText("Last updated \(Tracker.dateFormatter.stringFromDate(date))")
    }
    private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
        if originalPrice.isEqualToNumber(newPrice) {
            image.setHidden(true)
        } else {
            image.setImageNamed((newPrice.doubleValue > originalPrice.doubleValue) ? "Up" : "Down")
            image.setHidden(false)
        }
    }
}
