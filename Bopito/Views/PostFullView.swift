//
//  PostFullView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/18/24.
//

import SwiftUI
import Charts

struct PostFullView: View {
    
    private var coffeeSales = [
        (name: "Fire", count: 11),
        (name: "Logs", count: 37),
        (name: "Fire", count: 11),
        (name: "Water", count: 37),
        (name: "Fire", count: 11),
        (name: "Water", count: 37),
        
    ]
    let redItems: Set<String> = ["Coffee A", "Coffee B"]
    let blueItems: Set<String> = ["Coffee C", "Coffee D"]
    
    var body: some View {
 
        ScrollView {
            
            
            
            VStack (alignment:.leading, spacing:0){
                
                Divider()
                
                // Profile picture, username, etc
                HStack (spacing: 0) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.palette) // Allows foreground and background color customization
                        .foregroundStyle(.background, .secondary) // First color for the icon, second for the background
                        .frame(width: 50, height: 50)
                      VStack {
                        HStack {
                            Text("**@hans**")
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                            Text("3h")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                    }
                    .padding(.leading, 10)
                }.padding(10)
                
                // Submission Text
                HStack {
                    Text("Time to wake up buddy")
                    
                }.padding(10)
                
                // Image
                Image("SampleImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(.background)
                    .cornerRadius(10)
                    .padding(10)
                
                
                HStack {
                    // Share Submission
                    HStack {
                        Button(action: {
                            //
                        }) {
                            Image("share")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 21, height: 21)
                                .foregroundColor(.primary)
                            Text("18")
                                .foregroundColor(.primary)
                        }
                    }.padding(.leading, 5)
                    
                    
                    Spacer()
                    
                    // Comment on Submission
                    HStack {
                        Button(action: {
                            //
                        }) {
                            Image("comment")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                            Text("29")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Boost on Submission
                    HStack {
                        Button(action: {
                            //
                        }) {
                            Image("boost")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 23, height: 23)
                                .foregroundColor(.yellow)
                            Text("37")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // Fire / Water Buttons
                    
                    Button(action: {
                        //
                    }) {
                        Image("drop")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 23, height: 21)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        //
                    }) {
                        Text("493")
                            .foregroundColor(.primary)
                        Image("flame")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                            
                    }.padding(.trailing, 0)
                    
                    
                }
                .padding(10)
                
                // sample boosts
                HStack {
                    
                    Image("firetruck")
                        .resizable()
                        .frame(width: 70, height: 70)
                    Image("extinguisher")
                        .resizable()
                        .frame(width: 50, height: 50)
                }.padding(30)
                
                
            }
    
            
            
            
            
            
            
            
            
            VStack (spacing:0){
                
                Divider()
                    .padding(.top,100)
                
                HStack (alignment:.top, spacing:0) {
                    
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette) // Allows foreground and background color customization
                            .foregroundStyle(.background, .secondary) // First color for the icon, second for the background
                            .frame(width: 50, height: 50)
                    }
                    .padding(.leading, 10)
                    
                    VStack (spacing:8){
                        HStack {
                            Text("**@username**")
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                            Text("3h")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("This is a post with an image! This is a post with an image!")
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Picture
                        Image("SampleImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(.background)
                            .cornerRadius(10)
                        
                        HStack {
                            HStack {
                                Button(action: {
                                    //
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                    
                                }
                                Text("123")
                            }
                            .padding(5)
                            .background(.background)
                            .cornerRadius(10)
                            .shadow(color: Color.purple.opacity(0.2), radius: 2, x: 2, y: 2) // Add shadow
                            .shadow(color: Color.purple.opacity(0.2), radius: 2, x: -2, y: -2) // Add shadow
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    //
                                }) {
                                    Image(systemName: "ellipses.bubble.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                                Text("123")
                                    .padding(.trailing,1)
                                
                            }
                            .padding(5)
                            .background(.background)
                            .cornerRadius(10)
                            .shadow(color: Color.green.opacity(0.2), radius: 2, x: 2, y: 2) // Add shadow
                            .shadow(color: Color.green.opacity(0.2), radius: 2, x: -2, y: -2) // Add shadow
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    //
                                }) {
                                    Image("drop")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                    
                                }
                                Text("123")
                                Button(action: {
                                    //
                                }) {
                                    Image("flame")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                    
                                }
                            }
                            .padding(5)
                            .background(.background)
                            .cornerRadius(10)
                            .shadow(color: Color.red.opacity(0.2), radius: 3, x: 2, y: 2) // Add shadow
                            .shadow(color: Color.blue.opacity(0.2), radius: 3, x: -2, y: -2) // Add shadow
                            
                            
                        }
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal,10)
                    
                }
                
                Divider()
                
            }
            
            
            
            
        }

    }
}

#Preview {
    PostFullView()
}
