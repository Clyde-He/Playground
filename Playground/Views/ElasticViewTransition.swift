//
//  ElasticViewTransition.swift
//  Playground
//
//  Created by Clyde He on 3/8/24.
//

import SwiftUI

struct ElasticViewTransition: View {
    
    @State private var scrollOffset = 0.0
    var transitionThreshold = UIScreen.main.bounds.width / 4 * 3
    @State private var viewTransitioned = false
    
    var body: some View {
        
        VStack (spacing: 32) {
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 0) {
                        
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .foregroundColor(.red)
                            .aspectRatio(1 / 1, contentMode: .fit)
                            .containerRelativeFrame(.horizontal)
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .foregroundColor(.green)
                            .aspectRatio(3 / 4, contentMode: .fit)
                            .containerRelativeFrame(.horizontal)
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .foregroundColor(.blue)
                            .aspectRatio(9 / 14, contentMode: .fit)
                            .containerRelativeFrame(.horizontal)
                        GeometryReader { geometry in
                            Color.clear
                                .frame(width: 0, height: 0)
                                .onAppear {
                                    scrollOffset = geometry.frame(in: .global).minX
                                }
                                .onChange(of: geometry.frame(in: .global).minX) { _, newValue in
                                    scrollOffset = newValue
                                    if scrollOffset < transitionThreshold {
                                        viewTransitioned = true
                                        print(viewTransitioned)
                                    }
                                }
                        }
                        .frame(width: 0, height: 0)
                    }
                    .background(Color.gray)
                    
                    
                }
                .scrollTargetBehavior(.paging)
                
            }
            
            Text(String(format: "%.2f", scrollOffset))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.primary)
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .fill(Color.primary.opacity(0.03))
                    .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
//                .animation(.easeInOut(duration: 0.15), value: scrollOffset)
        }
    }
}

#Preview {
    ElasticViewTransition()
}
