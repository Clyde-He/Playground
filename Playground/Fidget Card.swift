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
    @State var dragDegree = CGPoint(x: 0, y: 0)
    var intensity : CGFloat = 20
    
    func linearScale(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
        return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
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
                            .degrees(dragDegree.x),axis: (x: 0.0, y: 1.0, z: 0.0),perspective: 1.0
                        )
                        .rotation3DEffect(
                            .degrees(-dragDegree.y),axis: (x: 1, y: 0.0, z: 0.0),perspective: 1.0
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged() { value in
                                    withAnimation(.interactiveSpring) {
                                        let normalizedX = linearScale(inMin: 0-cardWidth*0.2, inMax: cardWidth+cardWidth*0.2, outMin: -1, outMax: 1, inValue: value.location.x)
                                        let normalizedY = linearScale(inMin: 0-cardHeight, inMax: cardHeight+cardHeight, outMin: -1, outMax: 1, inValue: value.location.y)
                                        let dragDegreeX : CGFloat = sqrt(min(abs(normalizedX),1)) * intensity * normalizedX / abs(normalizedX)
                                        let dragDegreeY : CGFloat = sqrt(min(abs(normalizedY),1)) * intensity * normalizedY / abs(normalizedY)
                                        
                                        dragDegree = CGPoint(x: dragDegreeX, y: dragDegreeY)
                                    }
                                }
                                .onEnded() { _ in
                                    withAnimation(.spring(duration: 0.3, bounce: 0.7), {
                                        dragDegree = .zero
                                    })
                                }
                            
                        )
                    
                    //Parallax Overlay
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clyde He")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                        Text("@clyde_he")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .opacity(0.4)
                    }
                    .padding(24)
                    .frame(width: cardWidth, height: cardHeight, alignment: .bottomLeading)
                    .rotation3DEffect(
                        .degrees(dragDegree.x),
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        anchor: .center,
                        anchorZ: 0.0,
                        perspective: 0.5
                    )
                    .rotation3DEffect(
                        .degrees(-dragDegree.y),
                        axis: (x: 1.0, y: 0.0, z: 0.0),
                        anchor: .center,
                        anchorZ: 0.0,
                        perspective: 0.5
                    )
                    
                }
                HStack {
                    Text(String(format: "%.2f",dragDegree.x) + "," + String(format: "%.2f",dragDegree.y))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.primary)
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
                    .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
                .animation(.easeInOut(duration: 0.15), value: dragDegree)
            }
        }
    }
}

#Preview {
    FidgetCard()
}
