//
//  Motion Manager.swift
//  Playground
//
//  Created by Clyde He on 2/28/24.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    
    private let motionManager = CMMotionManager()
    @Published var motion: CMDeviceMotion?
    
    func startMotionManager() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) {receivedMotion, error in
            if let validMotion = receivedMotion {
                self.motion = validMotion
            }
        }
    }
    
    func stopMotioManager() {
        motionManager.stopDeviceMotionUpdates()
    }
}
