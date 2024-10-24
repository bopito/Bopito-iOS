//
//  ProfilePictureView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/6/24.
//
import SwiftUI

struct ProfilePictureView: View {
    
    @State var profilePictureURL: String?
    @State var refreshedURL: URL?
    
    
    var body: some View {
        ZStack {
            if let refreshedURL = refreshedURL {
                AsyncImage(url: refreshedURL) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        case .failure:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .task {
            await reloadURL()
        }
    }

    var placeholderImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .foregroundColor(.gray)
    }
    
    func reloadURL() async {
        if let profilePictureURL {
            refreshedURL = URL(string: "\(profilePictureURL)?timestamp=\(Date().timeIntervalSince1970)")
        }
    }
}

#Preview {
    ProfilePictureView()
}
