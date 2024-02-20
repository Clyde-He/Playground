//
//  Fidget Card.swift
//  Playground
//
//  Created by Clyde He on 2/19/24.
//

import SwiftUI

struct FidgetCard: View {
	
	@State var cardWidth : CGFloat = 320
	@State var cardHeight : CGFloat = 240
//	@State var rotationDegree : CGSize = (0,0)
	
    var body: some View {
		ZStack {
			
			//Background
			Color.red
				.ignoresSafeArea()
			
			VStack (spacing: 128) {
				
				Text("Some value")
				
				ZStack {
					
						//Colored Rectangle
					RoundedRectangle(cornerRadius: 24, style: .continuous)
						.fill(Color.blue)
						.frame(width: cardWidth, height: cardHeight)
					
						//Drag Card
					RoundedRectangle(cornerRadius: 20, style: .continuous)
						.fill(Color.black)
						.frame(width: cardWidth - 8, height: cardHeight - 8)
						.rotation3DEffect(
							.degrees(50),axis: (x: 0.0, y: 1.0, z: 0.0),perspective: 1.0
						)
						.gesture(TapGesture(count: 1).onEnded({
							cardWidth += 10
						}))
					
				}
				
			}
		}
    }
}

#Preview {
    FidgetCard()
}
