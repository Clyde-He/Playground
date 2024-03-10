//
//  ElasticViewTransition.swift
//  Playground
//
//  Created by Clyde He on 3/8/24.
//

import SwiftUI
import UIKit

struct ElasticViewTransition: View {
	
	var screenWidth = UIScreen.main.bounds.width
	var transitionThreshold = UIScreen.main.bounds.width * 0.3
	
	@State private var scrollOffset = 0.0
	@State private var scrollElasticOffset = 0.0
	@State private var profileActualSize = 48.0
	@State private var profileOffset = 0.0
	@State private var viewTransitioned = false
	
	@State private var showNavBar = true
	
	let impact = UIImpactFeedbackGenerator(style: .medium)
	@State private var impactOccurred = false
	
	func linearNormalization(inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, inValue: CGFloat) -> CGFloat {
		return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
	}
	
	var body: some View {
		
		GeometryReader { geometry in
			
			ZStack(alignment: .bottomTrailing) {
				
				VStack {
					
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 0) {
							
							RoundedRectangle(cornerRadius: 0, style: .continuous)
								.foregroundColor(.red)
								.aspectRatio(3 / 2, contentMode: .fit)
								.containerRelativeFrame(.horizontal)
							RoundedRectangle(cornerRadius: 0, style: .continuous)
								.foregroundColor(.green)
								.aspectRatio(1 / 1, contentMode: .fit)
								.containerRelativeFrame(.horizontal)
							RoundedRectangle(cornerRadius: 0, style: .continuous)
								.foregroundColor(.blue)
								.aspectRatio(3 / 4, contentMode: .fit)
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
											profileActualSize = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 48, outMax: 66, inValue: scrollElasticOffset)
											
											// Calculate ProfileOffset
											
											
											profileOffset = linearNormalization(inMin: 0, inMax: transitionThreshold, outMin: 0, outMax: (transitionThreshold - profileActualSize) / 2, inValue: scrollElasticOffset)
											
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
					.onAppear() {
						impact.prepare()
					}
					
					// Controls
					
					Spacer()
					
					VStack(spacing: 16) {
						Text(String(format: "%.2f, %.2f, %.2f", scrollElasticOffset, profileActualSize, profileOffset))
							.font(.system(size: 16, weight: .medium, design: .monospaced))
							.foregroundStyle(.primary.opacity(0.6))
							.padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
							.background(RoundedRectangle(cornerRadius: 8, style: .continuous)
								.fill(Color.primary.opacity(0.03)))
							.opacity(showNavBar ? 1 : 0)
						
						Button(action: {
							withAnimation(.linear) {
								showNavBar.toggle()
							}
						},
							   label: {
							Text("Hide Controls")
								.font(.system(size: 16, weight: .medium, design: .monospaced))
								.foregroundStyle(Color.primary)
								.padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
								.background(RoundedRectangle(cornerRadius: 48, style: .continuous)
									.fill(Color.primary.opacity(0.03))
									.strokeBorder(Color.primary.opacity(0.05), style: StrokeStyle(lineWidth: 1)))
								.opacity(showNavBar ? 1 : 0)
						})
					}
					
					Spacer()
					
				}
				.padding(.top, geometry.safeAreaInsets.top)
				.padding(.bottom, geometry.safeAreaInsets.bottom)
				
				// Profile View
				
				RoundedRectangle(cornerRadius: profileActualSize / 2, style: .continuous)
					.fill(.gray)
					.frame(width: viewTransitioned ? UIScreen.main.bounds.width : profileActualSize , height: viewTransitioned ? UIScreen.main.bounds.height : profileActualSize)
					.offset(x: viewTransitioned ? 0 : -6 - profileOffset , y: viewTransitioned ? 0 : -391)
					.gesture(
						TapGesture()
							.onEnded() {
								viewTransitioned.toggle()
								impact.impactOccurred()
								impactOccurred.toggle()
							}
					)
					.animation(.spring(duration: 0.3, bounce: 0.2), value: viewTransitioned)
			}
			.ignoresSafeArea()
		}
		.navigationBarTitleDisplayMode(.inline)
		.toolbar(showNavBar ? .visible : .hidden, for: .navigationBar)
	}
}

#Preview {
	ElasticViewTransition()
}
