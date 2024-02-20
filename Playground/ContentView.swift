	//
	//  ContentView.swift
	//  Playground
	//
	//  Created by Clyde He on 2/18/24.
	//

import SwiftUI

struct ContentView: View {
	
	var body: some View {
		TabView {
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
			ZStack (alignment: .topLeading){
				
				VStack (alignment: .leading, spacing: 4) {
					Text("Feb 20th, 2024")
						.font(.system(size: 16, weight: .medium, design: .rounded))
						.opacity(0.5)
					Text("Fidget Card")
						.font(.system(size: 28, weight: .bold, design: .rounded))
				}
				.padding(24)
				.background(Color.clear.ignoresSafeArea(edges: []))
				
				FidgetCard()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				
			}
		}
		.tabViewStyle(PageTabViewStyle())
	}
}



#Preview {
	ContentView()
}
