//
//  BoostsView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/24/24.
//

import SwiftUI
import Charts

struct BoostData {
    let category: String
    let count: Double
}

struct BoostsSheetView: View {
    // Sample data for the chart
    let boostData: [BoostData] = [
        BoostData(category: "pushesDead", count: 3),
        BoostData(category: "pullsDead", count: 2),
        BoostData(category: "pullsLive", count: 1),
        BoostData(category: "pushesLive", count: 7)
    ]
    
    var body: some View {
        VStack {
            
            //
            // Chart & Legend
            //
            HStack {
                // Chart
                ZStack {
                    Chart(boostData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.4),
                            angularInset: 2
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Category", item.category))
                        .annotation(position: .overlay) {
                            Text("\(Int(item.count))")
                                .foregroundStyle(.white)
                        }
                    }
                    .scaledToFit()
                    .chartLegend(.hidden)
                    .chartForegroundStyleScale(
                        ["pushesLive": .blue,
                         "pushesDead": Color(red: 0.1, green: 0.8, blue: 1.0),
                         "pullsLive": Color(red: 1.0, green: 0.3, blue: 0.3),
                         "pullsDead": Color(red: 1.0, green: 0.5, blue: 0.4),
                        ]
                    )
                    
                    Image("boost")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
                // Legend
                VStack {
                    HStack {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("7")
                                    .font(.title2)
                                Text("Live")
                            }.foregroundColor(.white)
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 0.1, green: 0.8, blue: 1.0))
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("3")
                                    .font(.title2)
                                Text("Dead")
                            }.foregroundColor(.white)
                        }
                    }
                    HStack {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("7")
                                    .font(.title2)
                                Text("Live")
                            }.foregroundColor(.white)
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.4))
                                .frame(width: 80, height: 70)
                                .cornerRadius(10)
                            VStack {
                                Text("3")
                                    .font(.title2)
                                Text("Dead")
                            }.foregroundColor(.white)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
            }

            
            Button(action: {
                
            }) {
                HStack (spacing:10) {
                    Text("🔥")
                    Text("+1")
                    Spacer()
                    Text("⏱️")
                        .font(.title)
                    Text("100")
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("5")
                    Spacer()
                    Text("Buy")
                    
                }
                .padding()
            }
            .font(.title2)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button(action: {
                
            }) {
                HStack (spacing:10) {
                    Text("🔥")
                    Text("-1")
                    Spacer()
                    Text("⏱️")
                        .font(.title)
                    Text("100")
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("5")
                    Spacer()
                    Text("Buy")
                    
                }
                .padding()
            }
            .font(.title2)
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(10)
            .padding(.horizontal)
         
            
            
            
            
            Spacer()
        }
       
    }
}

#Preview {
    BoostsSheetView() 
}
