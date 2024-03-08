//
//  Parallax Photo.swift
//  Playground
//
//  Created by Clyde He on 2/28/24.
//

import SwiftUI
import CoreMotion

struct ParallaxPhoto: View {
    
    @State private var pitch = 0.0
    @State private var roll = 0.0
    @State private var normalizedPitch = 0.0
    @State private var normalizedRoll = 0.0
    
    @ObservedObject var motionManager: MotionManager
    
    func linearNormalization(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
        return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    var body: some View {
        VStack {
            
            Image("Background")
                .resizable()
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(x: -80 * normalizedRoll, y: -80 * normalizedPitch)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .offset(x: 40 * normalizedRoll, y: 40 * normalizedPitch)
                .padding(32)
                .animation(.easeInOut(duration: 0.1), value: normalizedPitch)
                .animation(.easeInOut(duration: 0.1), value: normalizedRoll)
            
            
                
                Text(String(format: "%.2f", normalizedPitch) + "," + String(format: "%.2f", normalizedRoll))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.primary)
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
                        .fill(Color.primary.opacity(0.03))
                        .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
                    .animation(.easeInOut(duration: 0.15), value: normalizedPitch)
                    .animation(.easeInOut(duration: 0.15), value: normalizedRoll)
            
            
        }
        .onReceive(motionManager.$motion) { motion in
            pitch = motion?.attitude.pitch ?? 0
            if  (-1.5 < pitch) && (pitch < 1.5) {
                roll = motion?.attitude.roll ?? 0
            }
            else {
                roll = 0
            }
            
            normalizedPitch = linearNormalization(inMin: -Double.pi, inMax: Double.pi, outMin: -1, outMax: 1, inValue: pitch)
            normalizedRoll = linearNormalization(inMin: -Double.pi, inMax: Double.pi, outMin: -1, outMax: 1, inValue: roll)
            
        }
    }
}

#Preview {
    ParallaxPhoto(motionManager: MotionManager())
}
