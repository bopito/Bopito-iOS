//
//  SharesView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import SwiftUI

struct SharesView: View {
    var body: some View {
        Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 50, height: 5)
                .padding(.top, 20)
        
        Text("Shares")
            .font(.title2)
        
        Spacer()
    }
}

#Preview {
    SharesView()
}
