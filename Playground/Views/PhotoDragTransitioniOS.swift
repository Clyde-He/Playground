//
//  PhotoDragTransitioniOS.swift
//  Playground
//
//  Created by Clyde He on 3/13/24.
//

import SwiftUI
import UIKit
import ScrollUI

struct PhotoDragTransitioniOS: View {
    
    // MARK: Definition
    
	// Environments & Preferences
    var screenWidth = UIScreen.main.bounds.width
	var screenHeight = UIScreen.main.bounds.height
	@State private var transitionPercentage = 0.2
	@State private var transitionThreshold = UIScreen.main.bounds.width * 0.2
	@State private var hideControls = false
	@State private var showText = false
	@State private var filledArrow = false
	@State private var goDetailPage = false
	@State private var changeOpacity = false
	@State private var changeSize = true
	@State private var startSize = 12.0
	@State private var endSize = 32.0
	@State private var finalSize = 56.0
    
	// Scroll View
    @State private var scrollOffset = 0.0
    @State private var scrollElasticOffset = 0.0

	@State private var swipeIndicatorOffset = 48.0
	@State private var swipeIndicatorOpacity = 0.5
	@State private var swipeIndicatorSize = 32.0

	@State private var foregroundOpacity = 1.0
    @State private var viewTransitioned = false
	@State private var scrollViewDraggedToThreshold = false
    
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
				
                ZStack {
					
					// Swipe Indicator + Scroll View
					
					VStack {
						
						ZStack (alignment: .trailing) {
							
							// Swipe Indicator
							VStack(alignment:.center, spacing: 8) {
								
								ZStack {
									
									Image(filledArrow ? "Arrow_Left_Circle_Fill" : "Arrow_Left_Circle")
										.renderingMode(.template)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.opacity(scrollViewDraggedToThreshold ? 0 : 1)
									
									Image(goDetailPage ? "Detail_Circle_Fill" : "User_Circle_Fill")
										.renderingMode(.template)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.opacity(scrollViewDraggedToThreshold ? 1 : 0)
									
								}
								.frame(width: changeSize ? (scrollViewDraggedToThreshold ? finalSize : swipeIndicatorSize) : startSize, height: changeSize ? (scrollViewDraggedToThreshold ? finalSize : swipeIndicatorSize) : startSize)
								.clipShape(Circle())
								
								if showText {
									Text("Swipe to view profile")
										.font(.system(.subheadline, weight: .medium))
										.multilineTextAlignment(.center)
								}
							}
							.frame(maxWidth: 96)
							.foregroundStyle(.primary)
							.opacity(changeOpacity ? (scrollViewDraggedToThreshold ? 1 : swipeIndicatorOpacity) : 1)
							.offset(x: swipeIndicatorOffset)
							.animation(.smooth(duration: 0.2), value: scrollViewDraggedToThreshold)
							
							
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
													
													// Calculate swipeIndicatorSize
													swipeIndicatorSize = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: startSize, outMax: endSize, inValue: scrollElasticOffset)
													
													// Calculate swipeIndicatorOpacity
													swipeIndicatorOpacity = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 0.3, outMax: 0.7, inValue: scrollElasticOffset)
													
													// Calculate swipeIndicatorOffset
													swipeIndicatorOffset = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 48, outMax: (96 - transitionThreshold) / 2, inValue: scrollElasticOffset)
													
													// Calculate ForegroundOpacity
													foregroundOpacity = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 1, outMax: 0.5, inValue: scrollElasticOffset)
													
												}
												
												// See if ScrollView Reached TransitionThreshold
												
												if scrollOffset < screenWidth - transitionThreshold {
													reachedTransitionThreshold = true
                                                    print("Reached Transition Threshold")
													
												}
												else {
													reachedTransitionThreshold = false
												}
												
												// See if ScrollView Dragged
												
												if scrollViewDragged {
													if reachedTransitionThreshold {
														if !scrollViewDraggedToThreshold {
															mediumImpact.impactOccurred()
														}
														scrollViewDraggedToThreshold = true
														
													}
													else {
														scrollViewDraggedToThreshold = false
													}
												}
												else {
													if reachedTransitionThreshold {
														if scrollViewDraggedToThreshold {
															viewTransitioned = true
															scrollViewDragged = false
														}
													}
													else {
														scrollViewDraggedToThreshold = false
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
                            .onScrollPhaseChange{ oldPhase, newPhase in
                                if newPhase == .interacting {
                                    scrollViewDragged = true
                                }
                                else {
                                    scrollViewDragged = false
                                }
                            }
							.onTapGesture {
								withAnimation(.smooth(duration: 0.3)) {
									hideControls.toggle()
								}
							}
							.scrollTargetBehavior(.paging)
							
						}
						
						Spacer()
						
					}
					
					
					// Controls
					
					VStack {
						
						Spacer()
						
						VStack(alignment: .leading, spacing: 12) {
							
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
							
							Divider()
							
							HStack(spacing: 20) {
								Text("Go to Detail Page")
									.font(.system(size: 12, weight: .medium, design: .monospaced))
									.foregroundStyle(.secondary)
								Toggle(isOn: $goDetailPage, label:{})
							}
							
							Divider()
							
							HStack(spacing: 20) {
								Text("Use Filled Arrow Icon")
									.font(.system(size: 12, weight: .medium, design: .monospaced))
									.foregroundStyle(.secondary)
								Toggle(isOn: $filledArrow, label:{})
							}
							
							Divider()
							
							HStack(spacing: 20) {
								Text("Change Size")
									.font(.system(size: 12, weight: .medium, design: .monospaced))
									.foregroundStyle(.secondary)
								Toggle(isOn: $changeSize.animation(.smooth(duration: 0.3)), label:{})
								
							}
							
							VStack (spacing: 4) {
								
								HStack(spacing: 20) {
									
									Text("Min  ")
										.font(.system(size: 12, weight: .medium, design: .monospaced))
										.foregroundStyle(.secondary)
									
									Slider(value: $startSize,
										   in: 8...56,
										   step: 1
									)
									.onChange(of: startSize) {
										lightImpact.impactOccurred()
									}
									
									Text(String(format: "%.0f", startSize))
										.font(.system(size: 16, weight: .medium, design: .monospaced))
										.foregroundStyle(Color.primary)
									
								}
								
								if changeSize {
									
									HStack(spacing: 20) {
										
										Text("Max  ")
											.font(.system(size: 12, weight: .medium, design: .monospaced))
											.foregroundStyle(.secondary)
										
										Slider(value: $endSize,
											   in: 8...56,
											   step: 1
										)
										.onChange(of: endSize) {
											lightImpact.impactOccurred()
										}
										
										Text(String(format: "%.0f", endSize))
											.font(.system(size: 16, weight: .medium, design: .monospaced))
											.foregroundStyle(Color.primary)
										
									}
									
									HStack(spacing: 20) {
										
										Text("Final")
											.font(.system(size: 12, weight: .medium, design: .monospaced))
											.foregroundStyle(.secondary)
										
										Slider(value: $finalSize,
											   in: 8...56,
											   step: 1
										)
										.onChange(of: finalSize) {
											lightImpact.impactOccurred()
										}
										
										Text(String(format: "%.0f", finalSize))
											.font(.system(size: 16, weight: .medium, design: .monospaced))
											.foregroundStyle(Color.primary)
										
									}
									
								}
							}
							.padding(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 20))
							.background(RoundedRectangle(cornerRadius: 16, style: .continuous)
								.fill(Color.primary.opacity(0.05))
							)
							
							
							Divider()
							
							HStack(spacing: 20) {
								Text("Change Opacity")
									.font(.system(size: 12, weight: .medium, design: .monospaced))
									.foregroundStyle(.secondary)
								Toggle(isOn: $changeOpacity, label:{})
							}
							
						}
						.padding(EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20))
						.background(RoundedRectangle(cornerRadius: 24, style: .continuous)
							.fill(Material.thin)
							.strokeBorder(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 1)))
						.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
						.opacity(hideControls ? 0 : 1)
					
					}
					
                }
                .padding(.top, geometry.safeAreaInsets.top)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                
                // Foreground
                if hideControls {
                    Image("Foreground")
                        .resizable()
                        .allowsHitTesting(false)
                        .opacity(foregroundOpacity)
						.offset(x: viewTransitioned ? -screenWidth / 4 : 0, y: 0)
						.animation(.smooth(duration: 0.3), value: viewTransitioned)
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
				
				
				// Secondary View
				Image(goDetailPage ? "Detail Page" : "Profile")
					.resizable()
					.scaledToFit()
					.offset(x: viewTransitioned ? 0 : screenWidth)
					.animation(.smooth(duration: 0.3), value: viewTransitioned)
					.gesture(
						TapGesture()
							.onEnded() {
								viewTransitioned = false
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
    PhotoDragTransitioniOS()
}
