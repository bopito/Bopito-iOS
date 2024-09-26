//
//  BoostersView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/26/24.
//

import SwiftUI

struct BoostersView: View {
    var body: some View {
        Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 50, height: 5)
                .padding(.top, 20)
        
        Text("Warriors")
            .font(.title2)
        
        Spacer()
    }
}

#Preview {
    BoostersView()
}
