//
//  PhotoDragTransitionAndroid.swift
//  Playground
//
//  Created by Clyde He on 3/21/24.
//

import SwiftUI
import UIKit
import ScrollUI

struct PhotoDragTransitionAndroid: View {
	
	// Environments & Preferences
	var screenWidth = UIScreen.main.bounds.width
	var screenHeight = UIScreen.main.bounds.height
	@State private var transitionPercentage = 0.2
	@State private var transitionThreshold = UIScreen.main.bounds.width * 0.2
	@State private var hideControls = false
	
	// Scroll View
	
	@State private var dragOffset = 0.0
	@State private var normalizedDragOffset = 0.0
	
	@State private var swipeIndicatorOffset = 48.0
	@State private var swipeIndicatorOpacity = 0.4
	@State private var swipeIndicatorSize = 32.0
	
	@State private var foregroundOpacity = 1.0
	@State private var viewTransitioned = false
	
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
								ZStack {
									Image("TestPhoto03")
										.resizable()
										.aspectRatio(contentMode: .fit)
										.containerRelativeFrame(.horizontal)
										
									// Drag Rail
									
									Rectangle()
										.opacity(0.0001)
										.frame(height: 100)
										.gesture(
											DragGesture(minimumDistance: 0)
												.onChanged {value in
													dragOffset = value.translation.width
													
													if dragOffset < 0 {
														
														// Calculate swipeIndicatorOffset
														
														// Noramlize drag translation to 0...1
														normalizedDragOffset = linearNormalization(inMin: 0, inMax: -transitionThreshold, outMin: 0, outMax: 1, inValue: dragOffset)
														
														// Calculate Swipe Indicator Offset using exp
														let intensity = transitionThreshold + 48
														let calculatedOffset = (1 / (-exp(normalizedDragOffset)) + 1) * intensity
														swipeIndicatorOffset = -calculatedOffset + 48
														
														// Calculate foregroundOpacity
														foregroundOpacity = linearNormalization(inMin: 0, inMax: -intensity, outMin: 1, outMax: 0.4, inValue: swipeIndicatorOffset)
														
														// Trigger reached transition if dragOffset over threshold
														if abs(dragOffset) > transitionThreshold {
															if !reachedTransitionThreshold {
																mediumImpact.impactOccurred()
																reachedTransitionThreshold = true
                                                                withAnimation(.smooth(duration: 0.2)) {
                                                                    swipeIndicatorOpacity = 1
                                                                }
															}
														}
														else {
															reachedTransitionThreshold = false
                                                            withAnimation(.smooth(duration: 0.2)) {
                                                                swipeIndicatorOpacity = 0.4
                                                            }
														}
														
													}
													
												}
												.onEnded {_ in 
													withAnimation(.smooth(duration: 0.2)) {
														
														if abs(dragOffset) > transitionThreshold {
															viewTransitioned = true
														}
														
                                                        
														swipeIndicatorOpacity = 0.4
														foregroundOpacity = 1
														reachedTransitionThreshold = false
														dragOffset = 0
														normalizedDragOffset = 0
														swipeIndicatorOffset = 48
													}
												}
										)
								}
							}
							.frame(maxHeight: UIScreen.main.bounds.width / 3 * 4)
						}
						.onTapGesture {
							withAnimation(.smooth(duration: 0.3)) {
								hideControls.toggle()
							}
						}
						.scrollTargetBehavior(.paging)
						.onAppear {
							UIScrollView.appearance().bounces = false
						}
						.onDisappear {
							UIScrollView.appearance().bounces = true
						}
						
						// Swipe Indicator
						
						VStack(alignment:.center, spacing: 8) {
							
								Image("User")
									.renderingMode(.template)
									.resizable()
									.aspectRatio(contentMode: .fit)
//									.opacity(reachedTransitionThreshold ? 1 : 0.4)
                                    .opacity(swipeIndicatorOpacity)
//                                  .animation(.snappy, value: reachedTransitionThreshold)
                                    .frame(width: 24, height: 24)
								
						}
						.frame(width: 40, height: 40)
						.foregroundStyle(.black)
						.background(.white)
						.clipShape(Circle())
						.shadow(color: .black.opacity(0.19), radius: 1.5, x: 0, y: 0.5)
						.shadow(color: .black.opacity(0.039), radius: 1, x: 0, y: 0)
						.offset(x: swipeIndicatorOffset)
					}
					
					
					// Controls
					
					VStack(alignment: .leading, spacing: 16) {
						
						HStack(spacing: 20) {
							Text("Drag Translation")
								.font(.system(size: 12, weight: .medium, design: .monospaced))
								.foregroundStyle(.secondary)
							Spacer()
							Text(String(format: "%.2f", dragOffset))
								.font(.system(size: 16, weight: .medium, design: .monospaced))
								.foregroundStyle(Color.primary)
						}
						
						Divider()
						
						HStack(spacing: 20) {
							Text("Monitor")
								.font(.system(size: 12, weight: .medium, design: .monospaced))
								.foregroundStyle(.secondary)
							Spacer()
							Text(String(format: "%.2f, %.2f", normalizedDragOffset, swipeIndicatorOffset))
								.font(.system(size: 16, weight: .medium, design: .monospaced))
								.foregroundStyle(Color.primary)
						}
						
						Divider()
						
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
    PhotoDragTransitionAndroid()
}
