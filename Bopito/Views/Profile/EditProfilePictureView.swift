//
//  EditProfilePictureView.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/21/24.
//
import SwiftUI
import PhotosUI

struct EditProfilePictureView: View {
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data? = nil
    
    @StateObject private var viewModel = EditProfilePictureViewModel()
    
    var body: some View {
        NavigationStack {
            VStack (spacing:0){
                // Display the selected image or a placeholder
                HStack {
                    Button(action: {
                        
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Done")
                    })
                }
                .padding(.horizontal, 10)
                .padding(.top, 55)
                .padding(.bottom, 10)
                Group {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            .clipped()
                    } else {
                        Rectangle() // Placeholder image
                            .foregroundColor(Color(UIColor.systemBackground))
                            .overlay(
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    }
                }
                //.padding(.top, 50)
                
                PhotosPicker(
                    selection: $viewModel.selection,
                    maxSelectionCount: 1,
                    // Enable the app to dynamically respond to user adjustments.
                    selectionBehavior: .continuous,
                    matching: .images,
                    preferredItemEncoding: .current,
                    photoLibrary: .shared()
                ) {
                    Text("Select Photos")
                }
                .frame(height: 400)
                // Configure a half-height Photos picker.
                .photosPickerStyle(.inline)
                
                // Disable the cancel button for an inline use case.
                .photosPickerDisabledCapabilities(.selectionActions)
                
                // Hide padding around all edges in the picker UI.
                .photosPickerAccessoryVisibility(.hidden, edges: .all)
                .onChange(of: viewModel.selection) {
                    Task {
                        do {
                            // Try to load the image data
                            selectedImageData = try await viewModel.selection.first!.loadTransferable(type: Data.self)
                            print("Image loaded successfully.")
                            
                        } catch {
                            print("Failed to load image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EditProfilePictureView()
}
