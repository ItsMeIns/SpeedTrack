//
//  ActivityManager.swift
//  SpeedTrack
//
//  Created by macbook on 20.09.2023.
//

import UIKit
import CoreMotion

class Manager {
    static let share = Manager()
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    
    
}
