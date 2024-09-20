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
            Image("bopito-logo")
                .resizable()
                .frame(width: 128, height: 128)
                .padding(100)
            
            
            
            Button(action: {
                Task {
                    await supabaseManager.signOut()
                }
                
            }) {
                Text("Log out")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
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
