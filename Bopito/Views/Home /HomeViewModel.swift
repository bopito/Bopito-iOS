//
//  HomeViewModel.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/24/24.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
 
    @State var isComposing = false
    
    @State var submissions: [Submission]?
    
    @State var isLoading: Bool = true
    @State var error: Error?
    
    let feedTypes = ["All", "Following"]
    let feedFilters = ["New", "Hot", "Top"] // top posts expire after 7 days?
    
    @State var selectedFeedType = "All"
    @State var selectedFilterType = "New" // maybe randomize to inspire exploration for now?
    
    
}
