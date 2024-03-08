//
//  ListItem.swift
//  Playground
//
//  Created by Clyde He on 3/8/24.
//

import SwiftUI

struct ListItem: View {
    
    var destinationView: AnyView
    var title: String
    var date: String
    
    var body: some View {
        NavigationLink(destination: destinationView, label: {
            
            HStack {
                VStack (alignment: .leading, spacing: 4) {
                    Text(date)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .opacity(0.5)
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .opacity(0.3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.primary.opacity(0.03))
                .strokeBorder(Color.primary.opacity(0.10), style: StrokeStyle(lineWidth: 1)))
            .padding([.leading,.trailing],16)
            .foregroundStyle(Color.primary)
        })
    }
}

#Preview {
    ListItem(destinationView: AnyView(ElasticViewTransition()), title: "Elastic View Transition", date: "Mar 8th, 2024")
}
