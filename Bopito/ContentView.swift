//
//  ContentView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State var isChecked: Bool = false
    
    var body: some View {
        
        ZStack {
            if supabaseManager.isAuthenticated {
                AppView() // Show app content when authenticated
            } else {
                VStack {
                    Button(action: {
                        Task {
                            await supabaseManager.signInAnonymously()
                        }
                    }) {
                        Text("I accept EULA terms")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    Toggle(isOn: $isChecked) {
                                    // Label
                                    Text("I accept the User Agreement")
                                        .font(.headline)
                                }
                }
            }
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(SupabaseManager())
      
    
}
