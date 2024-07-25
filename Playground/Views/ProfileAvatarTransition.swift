//
//  ElasticViewTransition.swift
//  Playground
//
//  Created by Clyde He on 3/8/24.
//

import SwiftUI
import UIKit

struct ProfileAvatarTransition: View {
	
	var screenWidth = UIScreen.main.bounds.width
	var transitionThreshold = UIScreen.main.bounds.width * 0.25
	
	@State private var scrollOffset = 0.0
	@State private var scrollElasticOffset = 0.0
	@State private var profileActualSize = 44.0
	@State private var profileOffset = 0.0
	@State private var foregroundOpacity = 1.0
	@State private var viewTransitioned = false
	
	@State private var hideControls = false
	
	let impact = UIImpactFeedbackGenerator(style: .medium)
	@State private var impactOccurred = false
	
	@Environment(\.colorScheme) var colorScheme
	@State private var isDarkModeEnabled = false
	
	func linearNormalization(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
		return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
	}
	
	var body: some View {
		
		GeometryReader { geometry in
			
			ZStack(alignment: .bottomTrailing) {
				
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
										scrollOffset = newValue
										
										if scrollOffset <= screenWidth {
											scrollElasticOffset = screenWidth - scrollOffset
											
											// Calculate ProfileActualSize
											profileActualSize = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 44, outMax: 66, inValue: scrollElasticOffset)
											
											// Calculate ProfileOffset
											profileOffset = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 0, outMax: (transitionThreshold - profileActualSize) / 2, inValue: scrollElasticOffset)
											
											// Calculate ForegroundOpacity
											foregroundOpacity = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 1, outMax: 0.5, inValue: scrollElasticOffset)
											
										}
										
										
										// Toggle transition
										
										if scrollOffset < screenWidth - transitionThreshold {
											viewTransitioned = true
											if !impactOccurred {
												impact.impactOccurred()
												impactOccurred.toggle()
											}
											
										}
									}
							}
							.frame(width: 0, height: 0)
						}
						.frame(maxHeight: UIScreen.main.bounds.width / 3 * 4)
					}
					.scrollTargetBehavior(.paging)
					
					// Controls
					
					Spacer()
					
					VStack(spacing: 16) {
						Text(String(format: "%.2f, %.2f, %.2f", scrollElasticOffset, profileActualSize, profileOffset))
							.font(.system(size: 16, weight: .medium, design: .monospaced))
							.foregroundStyle(Color.primary)
							.padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
							.background(RoundedRectangle(cornerRadius: 48, style: .continuous)
								.fill(Color.primary.opacity(0.05))
								.strokeBorder(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 1)))
							.opacity(hideControls ? 0 : 1)
					}
					
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
				
				// Profile View
				
				ZStack {
					Image("UserAvatar")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.opacity(viewTransitioned ? 0 : 1)
					Image("Profile")
						.resizable()
						.aspectRatio(contentMode: .fill)
						.opacity(viewTransitioned ? 1 : 0)
				}
				.background(.white)
				.frame(width: viewTransitioned ? UIScreen.main.bounds.width : profileActualSize , height: viewTransitioned ? UIScreen.main.bounds.height : profileActualSize)
				.clipShape(RoundedRectangle(cornerRadius: profileActualSize / 2, style: .continuous))
				.offset(x: viewTransitioned ? 0 : -6 - profileOffset , y: viewTransitioned ? 0 : -381)
				.gesture(
					TapGesture()
						.onEnded() {
							viewTransitioned.toggle()
							impact.impactOccurred()
							impactOccurred.toggle()
						}
				)
				.animation(.smooth(duration: 0.35), value: viewTransitioned)
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
	ProfileAvatarTransition()
}
