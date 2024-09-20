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
 
        
        VStack (spacing:0){
            
            Divider()
            
            HStack (alignment:.top, spacing:0) {
                
                VStack {
                    Circle()
                        .frame(width: 60, height: 60)
                        .padding(.top, 10)
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
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2) // Add shadow
                    
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
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                            }
                            Text("123")
                            Button(action: {
                                //
                            }) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                                
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

#Preview {
    PostFullView()
}
