//
//  ContentView.swift
//  Bopito
//
//  Created by Hans Heidmann on 8/28/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var isOutdated = false
    @State private var latestVersion: String?
    @State private var currentVersion: String?
    @State private var isDevelopment = true // Set this to true during development to bypass
    
    
    var body: some View {
        
        VStack {
            if isOutdated {
                Text("A new version is available! Please update the app.")
                    .foregroundColor(.red)
                    .padding()
                Button("Update Now") {
                    // Open App Store for updating
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id{your_app_id}") {
                        UIApplication.shared.open(url)
                    }
                }
                
            } else {
                if supabaseManager.isAuthenticated {
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        AppView()
                            .task {
                                print("In Preview so FCM Push Notifications don't work")
                            }
                    }
                    else {
                        AppView() // Show app content when authenticated
                            .task {
                                //print("Trying to upsert FCM Token")
                                //await supabaseManager.addFirebaseCloudMessengerToken(token:token)
                            }
                    }
                } else {
                    VStack {
                        
                        Spacer()
                        
                        Image("bopito-logo")
                            .resizable()
                            .frame(width: 128, height: 128)
                            .padding(100)
                        
                        Button(action: {
                            Task {
                                await supabaseManager.signInAnonymously()
                            }
                        }) {
                            Text("Let's Go!")
                                .font(.headline)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("By continuing, you agree to Bopito's ")
                                .font(.caption)
                            +
                            Text("[Terms of Service](https://bopito.com/privacy-policy)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            +
                            Text(" and confirm that you have read and understand the ")
                                .font(.caption)
                            +
                            Text("[Privacy Policy](https://bopito.com/privacy-policy)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            +
                            Text(".")
                                .font(.caption)
                        }
                        .padding(40)
                        
                    }
                    
                    
                }
            }
            
            
        }
        .onAppear {
            Task {
                // Check for Updates
                await checkForUpdate()
            }
        }
        
    }
    
    
    
    func checkForUpdate() async {
        print("test1")
        let isCurrent = await supabaseManager.appVersionCurrent()
        print("test2")
        if !isCurrent {
            // Handle the case where the app version is outdated
            isOutdated = true
        } else {
            isOutdated = false
        }
        
    }
}



#Preview {
    ContentView()
        .environmentObject(SupabaseManager())
        .environmentObject(NotificationManager())
    
    
}
