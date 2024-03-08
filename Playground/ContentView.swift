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
        
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 8) {
                    ListItem(destinationView: AnyView(ElasticViewTransition()), title: "Elastic View Transition", date: "Mar 8th, 2024")
                    ListItem(destinationView: AnyView(ParallaxPhoto(motionManager: motionManager)), title: "Parallax Photo", date: "Feb 28th, 2024")
                    ListItem(destinationView: AnyView(FidgetCard()), title: "Fidget Card", date: "Feb 20th, 2024")
                    ListItem(destinationView: AnyView(ProfileCard()), title: "Profile Card", date: "Feb 19th, 2024")
                    
                }
            }
            .contentMargins([.top],16)
            .frame(maxWidth: .infinity)
            .navigationTitle("Playground")
            
        }
        .background(.black)
        .padding(0)
        .onAppear {
            motionManager.startMotionManager()
        }
	}
}



#Preview {
	ContentView()
}
