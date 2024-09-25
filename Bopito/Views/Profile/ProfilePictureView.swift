//
//  ProfilePictureView.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/6/24.
//
import SwiftUI

struct ProfilePictureView: View {
    
    @State var profilePictureURL: String?

    var body: some View {
        ZStack {
            if let urlString = profilePictureURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
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
    }

    var placeholderImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .foregroundColor(.gray)
    }
}

#Preview {
    ProfilePictureView()
}
