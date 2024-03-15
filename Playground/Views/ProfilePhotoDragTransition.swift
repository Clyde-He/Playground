//
//  ProfilePhotoDragTransition.swift
//  Playground
//
//  Created by Clyde He on 3/13/24.
//

import SwiftUI
import UIKit
import ScrollUI

struct ProfilePhotoDragTransition: View {
    
    var screenWidth = UIScreen.main.bounds.width
	var screenHeight = UIScreen.main.bounds.height
    var transitionThreshold = UIScreen.main.bounds.width * 0.25
    
    @State private var scrollOffset = 0.0
    @State private var scrollElasticOffset = 0.0
    @State private var profileActualSize = 48.0
    @State private var profileOffset = 0.0
    @State private var foregroundOpacity = 1.0
    @State private var viewTransitioned = false
    
    @State private var hideControls = false
    
    @State private var scrollViewDragged = false
    @State private var newScrollOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State private var scollViewWidth = 0.0
    @ScrollState var state
    
    let impact = UIImpactFeedbackGenerator(style: .medium)
    @State private var reachedTransitionThreshold = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkModeEnabled = false
    
    func linearNormalization(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
        return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
				
				
				// ScrollView and Monitor
                
                VStack {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 0) {
                            
                            Image("TestPhoto01")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.horizontal)
                            Image("TestPhoto02")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.horizontal)
                            Image("TestPhoto03")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.horizontal)
                            GeometryReader { geometry in
                                Color.clear
                                    .frame(width: 0, height: 0)
                                    .onAppear {
                                        scrollOffset = geometry.frame(in: .global).minX
                                    }
                                    .onChange(of: geometry.frame(in: .global).minX) { _, newValue in
                                        
                                        // Read scrollOffset
                                        scrollOffset = newValue
                                        
                                        if scrollOffset <= screenWidth {
                                            scrollElasticOffset = screenWidth - scrollOffset
                                            
                                            // Calculate ProfileActualSize
                                            profileActualSize = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 48, outMax: 66, inValue: scrollElasticOffset)
                                            
                                            // Calculate ProfileOffset
                                            profileOffset = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 0, outMax: (transitionThreshold - profileActualSize) / 2, inValue: scrollElasticOffset)
                                            
                                            // Calculate ForegroundOpacity
                                            foregroundOpacity = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 1, outMax: 0.5, inValue: scrollElasticOffset)
                                            
                                        }
                                        
                                        // Toggle transition
                                        
                                        if scrollOffset < screenWidth - transitionThreshold {
                                            if !reachedTransitionThreshold {
                                                impact.impactOccurred()
												reachedTransitionThreshold = true
                                            }
                                            if !scrollViewDragged {
                                                viewTransitioned = true
                                            }
                                        }
                                        else {
											if reachedTransitionThreshold {
												impact.impactOccurred()
												reachedTransitionThreshold = false
											}
                                        }
                                    }
                            }
                            .frame(width: 0, height: 0)
                        }
                        .frame(maxHeight: UIScreen.main.bounds.width / 3 * 4)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        scollViewWidth = proxy.size.width
                                    }
                            }
                        )
                    }
                    .scrollViewStyle(.defaultStyle($state))
                    .onChange(of: state.isDragging) { _, newValue in
                        scrollViewDragged = newValue
                        
                    }
                    .scrollTargetBehavior(.paging)
                    
                    
                    // Monitor
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        
                        Text(String(format: "%.2f, %.2f", newScrollOffset.x, scollViewWidth))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.primary)
                            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                            .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .fill(Color.primary.opacity(0.03))
                                .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
                            .opacity(hideControls ? 0 : 1)
                        
//                        Text(String(format: "%.2f, %.2f, %.2f", scrollElasticOffset, profileActualSize, profileOffset))
//                            .font(.system(size: 16, weight: .medium, design: .monospaced))
//                            .foregroundStyle(Color.primary)
//                            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
//                            .background(RoundedRectangle(cornerRadius: 48, style: .continuous)
//                                .fill(Color.primary.opacity(0.03))
//                                .strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
//                            .opacity(hideControls ? 0 : 1)
                    }
                    
                    Spacer()
                    
                }
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
				// Drag Indicator
				
				VStack(alignment:.center, spacing: 8) {
					
					ZStack {
						Image("Arrow_Left_Circle_Fill")
							.renderingMode(.template)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.opacity(reachedTransitionThreshold ? 0 : 1)
							
						Image("User_Circle_Fill")
							.renderingMode(.template)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.opacity(reachedTransitionThreshold ? 1 : 0)
					}
					.frame(width: reachedTransitionThreshold ? 40 : 24, height: reachedTransitionThreshold ? 40 : 24)
					.clipShape(Circle())
						
					Text("Swipe to view profile")
						.font(.system(.subheadline, weight: .medium))
						.multilineTextAlignment(.center)
						.frame(maxWidth: 96)
				}
				.foregroundStyle(.primary)
				.opacity(reachedTransitionThreshold ? 1 : 0.4)
				.padding()
				.background()
				.animation(.smooth(duration: 0.2), value: reachedTransitionThreshold)
                
                // Foreground
                
                if hideControls {
                    Image("Foreground")
                        .resizable()
                        .allowsHitTesting(false)
                        .opacity(foregroundOpacity)
                    
                }
                
                // Profile
				
				HStack (alignment: .center) {
					Image("UserAvatar")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 48, height:48)
						.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
						.offset(x: -6, y: -424)
						.gesture(
							TapGesture()
								.onEnded() {
									viewTransitioned.toggle()
									impact.impactOccurred()
								}
						)
				}
				.frame(width: screenWidth, height: screenHeight, alignment: .bottomTrailing)
				
            }
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.smooth(duration: 0.3)) {
                    hideControls.toggle()
                }
            }
        }
        .onAppear() {
            if colorScheme == .dark {
                isDarkModeEnabled = true
            }
            impact.prepare()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(hideControls ? .hidden : .visible, for: .navigationBar)
        .environment(\.colorScheme, hideControls ? .dark : (isDarkModeEnabled ? .dark : .light))
        
    }
}

#Preview {
    ProfilePhotoDragTransition()
}
