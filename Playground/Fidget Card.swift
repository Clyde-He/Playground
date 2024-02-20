//
//  Fidget Card.swift
//  Playground
//
//  Created by Clyde He on 2/19/24.
//

import SwiftUI

struct FidgetCard: View {
    
    @State var cardWidth : CGFloat = 320
    @State var cardHeight : CGFloat = 240
    @State var dragLocation = CGPoint(x: 0, y: 0)
    var intensity : CGFloat = 10
    
    func linearScale(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
        return inValue * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    var body: some View {
        ZStack {
            
            VStack (spacing: 48) {
                
                ZStack {
                    
                    //Colored Rectangle
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.blue)
                        .frame(width: cardWidth, height: cardHeight)
                    
                    //Drag Card
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: cardWidth - 8, height: cardHeight - 8)
                        .rotation3DEffect(
                            .degrees(dragLocation.x),axis: (x: 0.0, y: 1.0, z: 0.0),perspective: 1.0
                        )
                        .rotation3DEffect(
                            .degrees(-dragLocation.y),axis: (x: 1, y: 0.0, z: 0.0),perspective: 1.0
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged() { value in
                                    withAnimation(.interactiveSpring) {
                                        dragLocation = CGPoint(x: linearScale(inMin: 0, inMax: cardWidth, outMin: -intensity, outMax: intensity, inValue: value.location.x), y: linearScale(inMin: 0, inMax: cardHeight, outMin: -intensity, outMax: intensity, inValue: value.location.y))
                                    }
                                }
                                .onEnded() { _ in
                                    withAnimation(.spring(duration: 0.3, bounce: 0.7), {
                                        dragLocation = .zero
                                    })
                                }
                            
                        )
                    
                }
                HStack {
                    Text(String(format: "%.2f",dragLocation.x) + "," + String(format: "%.2f",dragLocation.y))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.primary)
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
                    .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
                .animation(.easeInOut(duration: 0.15), value: dragLocation)
            }
        }
    }
}

#Preview {
    FidgetCard()
}
