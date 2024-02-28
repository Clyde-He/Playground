	//
	//  ContentView.swift
	//  Playground
	//
	//  Created by Clyde He on 2/18/24.
	//

import SwiftUI

struct ContentView: View {
    
    @StateObject var motionManager = MotionManager()
    
	var body: some View {
		TabView {
            
            // Profile Card
			ZStack (alignment: .topLeading){
				VStack (alignment: .leading, spacing: 4) {
					Text("Feb 19th, 2024")
						.font(.system(size: 16, weight: .medium, design: .rounded))
						.opacity(0.5)
					Text("Profile Card")
						.font(.system(size: 28, weight: .bold, design: .rounded))
				}
				.padding(24)
				.background(Color.clear.ignoresSafeArea(edges: []))
				
				ProfileCard()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				
			}
            
            // Fidget Card
			VStack (alignment: .leading){
				VStack (alignment: .leading, spacing: 4) {
					Text("Feb 20th, 2024")
						.font(.system(size: 16, weight: .medium, design: .rounded))
						.opacity(0.5)
					Text("Fidget Card")
						.font(.system(size: 28, weight: .bold, design: .rounded))
				}
				.padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
				.background(Color.clear.ignoresSafeArea(edges: []))
				
				FidgetCard()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 48)
			}
            
            VStack (alignment: .leading){
                VStack (alignment: .leading, spacing: 4) {
                    Text("Feb 28th, 2024")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .opacity(0.5)
                    Text("Parallax Photo")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
                .background(Color.clear.ignoresSafeArea(edges: []))
                
                ParallaxPhoto(motionManager: motionManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 64)
            }
            
		}
		.tabViewStyle(PageTabViewStyle())
        .onAppear {
            motionManager.startMotionManager()
        }
	}
}



#Preview {
	ContentView()
}
