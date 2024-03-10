	//
	//  Profile Card.swift
	//  Playground
	//
	//  Created by Clyde He on 2/19/24.
	//

import Foundation
import SwiftUI

struct ProfileCard: View {
	
	@State var isActive = false
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: isActive ? "checkmark.seal.fill" : "person.circle.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 44)
				.foregroundStyle(isActive ? Color.white : .primary)
				.opacity(0.6)
				.rotationEffect(isActive ? .degrees(360) : .degrees(0))
			VStack(alignment: .leading, spacing: 4) {
				Text("Clyde He")
					.font(.system(size: 24, weight: .bold, design: .serif))
				Text("@clyde_he")
					.font(.system(size: 16, weight: .regular, design: .monospaced))
					.opacity(0.4)
			}
			.foregroundColor(isActive ? .white : .primary)
		}
		.padding([.top, .leading, .bottom], 24)
		.padding(.trailing, 32)
		.background(
			RoundedRectangle(cornerRadius: 128, style: .continuous)
				.fill(isActive ? .blue : .clear)
				.strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
		)
		
		.scaleEffect(isActive ? 1.4 : 1)
		.onTapGesture {
			withAnimation(.bouncy(duration: 0.6)) {
				isActive = !isActive
			}
		}
		.navigationTitle("Profile Card")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	ProfileCard()
}
