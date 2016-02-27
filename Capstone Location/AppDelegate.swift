//
//  AppDelegate.swift
//  Capstone Location
//
//  Created by Kyle Bailey on 11/13/15.
//  Copyright © 2015 Kyle Bailey. All rights reserved.
//

import UIKit
import Parse

import Fabric
import Crashlytics

let floorPlanConfig: AnchoredFloorPlanConfiguation = {
    let a1 = AnchorPoint(
        floor: FloorPoint(x: 381, y: 456),
        world: WorldPoint(latitude: 40.521807, longitude: -74.461135)
    )
    
    let a2 = AnchorPoint(
        floor: FloorPoint(x: 974, y: 1736),
        world: WorldPoint(latitude: 40.521776, longitude: -74.460533)
    )
    
    let images = [FloorPlanImage(named: "floor0")!, FloorPlanImage(named: "floor1")!, FloorPlanImage(named: "floor2")!]
    
    return AnchoredFloorPlanConfiguation(images: images, initialFloor: 1, beacons: [], a1: a1, a2: a2)
}()

let baseStations = [
"8C2C082F-26F5-84BE-5099-127ABF541F1E",
"75E391DF-2A81-55A1-9DE3-24EDF8886E00",
"E970E05E-A7B0-F5D5-DCF6-CDB47E74AA3D"
]

let sampleDatabase = ParseSampleDatabase(baseStations: baseStations)
let sensorManager = BluetoothSensorManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

