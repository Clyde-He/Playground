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
    
	// Environments & Preferences
    var screenWidth = UIScreen.main.bounds.width
	var screenHeight = UIScreen.main.bounds.height
	@State private var transitionPercentage = 0.25
	@State private var transitionThreshold = UIScreen.main.bounds.width * 0.25
	@State private var hideControls = false
	@State private var showText = true
    
	// Scroll View
    @State private var scrollOffset = 0.0
    @State private var scrollElasticOffset = 0.0
	@State private var swipeIndicatorOffset = 48.0
    @State private var foregroundOpacity = 1.0
    @State private var viewTransitioned = false
    
	// ScrollUI
    @State private var scrollViewDragged = false
    @State private var newScrollOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State private var scollViewWidth = 0.0
    @ScrollState var state
    
	// Haptic Feedback
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
	let lightImpact = UIImpactFeedbackGenerator(style: .light)
    @State private var reachedTransitionThreshold = false
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkModeEnabled = false
    
    func linearNormalization(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
        return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
			// + Foreground + User Avatar + Profile View
            
			ZStack {
                
				// + Controls
				
                VStack {
					
					// Swipe Indicator + Scroll View
					
					ZStack (alignment: .trailing) {
						
						
						// Swipe Indicator
						
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
							
							if showText {
								Text("Swipe to view profile")
									.font(.system(.subheadline, weight: .medium))
									.multilineTextAlignment(.center)
							}
						}
						.frame(maxWidth: 96)
						.foregroundStyle(.primary)
						.opacity(reachedTransitionThreshold ? 1 : 0.4)
						.offset(x: swipeIndicatorOffset)
						.animation(.smooth(duration: 0.2), value: reachedTransitionThreshold)
						
						
						// ScrollView
						
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
												
												// Calculate swipeIndicatorOffset
												swipeIndicatorOffset = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 48, outMax: (96 - transitionThreshold) / 2, inValue: scrollElasticOffset)
												
												// Calculate ForegroundOpacity
												foregroundOpacity = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 1, outMax: 0.5, inValue: scrollElasticOffset)
												
											}
											
											// Toggle transition
											
											if scrollOffset < screenWidth - transitionThreshold {
												if !reachedTransitionThreshold {
													mediumImpact.impactOccurred()
													reachedTransitionThreshold = true
												}
												if !scrollViewDragged {
													viewTransitioned = true
												}
											}
											else {
												if reachedTransitionThreshold {
													mediumImpact.impactOccurred()
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
						.onTapGesture {
							withAnimation(.smooth(duration: 0.3)) {
								hideControls.toggle()
							}
						}
						.scrollTargetBehavior(.paging)
						
					}
                    
                    
                    // Controls
                    
					VStack(alignment: .leading, spacing: 16) {
						
						Text("Transition Percentage")
							.font(.system(size: 12, weight: .medium, design: .monospaced))
							.foregroundStyle(.secondary)
						
						
						HStack(spacing: 20) {
							
							Slider(value: $transitionPercentage,
								   in: 0.1...0.4,
								   step: 0.01,
								   onEditingChanged: { _ in
								transitionThreshold = transitionPercentage * screenWidth
							})
							.onChange(of: transitionPercentage) {
								lightImpact.impactOccurred()
							}
							
							Text(String(format: "%.2f", transitionPercentage))
								.font(.system(size: 16, weight: .medium, design: .monospaced))
								.foregroundStyle(Color.primary)
							
						}
						
						Divider()
						
						HStack(spacing: 20) {
							Text("Show Text")
								.font(.system(size: 12, weight: .medium, design: .monospaced))
								.foregroundStyle(.secondary)
							Toggle(isOn: $showText, label:{})
						}
						
					}
					.padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
					.background(RoundedRectangle(cornerRadius: 16, style: .continuous)
						.fill(Color.primary.opacity(0.05))
						.strokeBorder(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 1)))
					.padding(32)
					.opacity(hideControls ? 0 : 1)
					
                    Spacer()
                    
                }
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                // Foreground
                
                if hideControls {
                    Image("Foreground")
                        .resizable()
                        .allowsHitTesting(false)
                        .opacity(foregroundOpacity)
                }
                
                // User Avatar
				
				if hideControls {
					HStack (alignment: .center) {
						Image("UserAvatar")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 48, height: 48)
							.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
							.offset(x: -6, y: -424)
							.opacity(foregroundOpacity)
							.gesture(
								TapGesture()
									.onEnded() {
										viewTransitioned.toggle()
										mediumImpact.impactOccurred()
									}
							)
					}
					.frame(width: screenWidth, height: screenHeight, alignment: .bottomTrailing)
				}
				
				
				// Profile View
				
				Image("Profile")
					.resizable()
					.scaledToFit()
					.offset(x: viewTransitioned ? 0 : screenWidth)
					.animation(.smooth(duration: 0.3), value: viewTransitioned)
					.gesture(
						TapGesture()
							.onEnded() {
								viewTransitioned.toggle()
								mediumImpact.impactOccurred()
							}
					)
				
            }
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea()
        }
        .onAppear() {
            if colorScheme == .dark {
                isDarkModeEnabled = true
            }
            mediumImpact.prepare()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(hideControls ? .hidden : .visible, for: .navigationBar)
        .environment(\.colorScheme, hideControls ? .dark : (isDarkModeEnabled ? .dark : .light))
        
    }
}

#Preview {
    ProfilePhotoDragTransition()
}
