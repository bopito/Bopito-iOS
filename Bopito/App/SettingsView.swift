//
//  SettingsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var newDisplayName: String = ""
    @State private var updateStatus: String = ""
    
    var body: some View {
        VStack {
            
            Text("settings")
                .font(.largeTitle)
                .padding()
            
            
            Image(systemName: "person.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            
            
            Button(action: {
                Task {
                    await supabaseManager.signOut()
                }
                
            }) {
                Text("Logout")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        SettingsView()
            .environmentObject(SupabaseManager())
    }
}
