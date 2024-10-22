//
//  EditProfilePictureView.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/21/24.
//
import SwiftUI
import PhotosUI

struct EditProfilePictureView: View {
    
    @EnvironmentObject var supabaseManager: SupabaseManager
    @Environment(\.presentationMode) var presentationMode // Add this line to access presentation mode
    @StateObject private var viewModel = EditProfilePictureViewModel()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data? = nil
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack (spacing:0){
                // Display the selected image or a placeholder
                ZStack {
                    HStack {
                        Spacer()
                        Text("Library")
                            .font(.title2)
                        Spacer()
                    }
                    
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Text("Cancel")
                        })
                        Spacer()
                        Button(action: {
                            Task {
                                await doneButtonPressed()
                            }
                        }, label: {
                            Text("Done")
                        })
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 65)
                .padding(.bottom, 5)
                    
                ZStack {
                    // Display the selected image or a placeholder
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            .scaleEffect(scale)
                            .offset(x: offset.width, y: offset.height)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        // Calculate the new offset with boundaries
                                        let widthBound = (UIScreen.main.bounds.width / 2) * scale
                                        let heightBound = (UIScreen.main.bounds.width / 2) * scale
                                        
                                        // Snap back to screen edges
                                        if offset.width < -widthBound {
                                            offset.width = 0
                                        } else if offset.width > widthBound {
                                            offset.width = 0
                                        }
                                        
                                        if offset.height < -heightBound {
                                            offset.height = 0
                                        } else if offset.height > heightBound {
                                            offset.height = 0
                                        }
                                        
                                        // Store the last offset
                                        lastOffset = offset
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    }
                            )
                            .clipped()
                        
                        
                        // Dark overlay with a circular mask
                        Color.black.opacity(0.55)
                            .mask(
                                ZStack {
                                    Rectangle() // Full-screen rectangle
                                    Circle() // The circular "hole" in the mask
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                                        .blendMode(.destinationOut) // Remove the circle part from the mask
                                }
                            )
                            .compositingGroup() // Needed for proper blending
                            .allowsHitTesting(false)
                    
                    } else {
                        // Placeholder for when no image is selected
                        ZStack {
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 120))
                        }
                        // Dark overlay with a circular mask
                        Color.black.opacity(0.55)
                            .mask(
                                ZStack {
                                    Rectangle() // Full-screen rectangle
                                    Circle() // The circular "hole" in the mask
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                                        .blendMode(.destinationOut) // Remove the circle part from the mask
                                }
                            )
                            .compositingGroup() // Needed for proper blending
                            .allowsHitTesting(false)
                    }
                }
                .ignoresSafeArea() // Ensure the ZStack covers the whole screen
                .padding(.bottom, 2)
                
               
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
                        } catch {
                            print("Failed to load image: \(error.localizedDescription)")
                        }
                        scale = 1.0
                        lastScale = 1.0
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
        }
    }
    
    func doneButtonPressed() async {
        guard let selectedImageData else {
            print("selectedImageData not set")
            return
        }
        guard let image = UIImage(data: selectedImageData) else {
            print("Couldn't turn selectedImageData into a UIImage")
            return
        }
        let size = image.size
        let cropRect = CGRect(
            x: (size.width / 2) - (UIScreen.main.bounds.width / 2) * scale + offset.width,
            y: (size.height / 2) - (UIScreen.main.bounds.width / 2) * scale + offset.height,
            width: UIScreen.main.bounds.width * scale,
            height: UIScreen.main.bounds.width * scale
        )
        // Create a CGImage from the original UIImage
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            print("Could not crop image.")
            return
        }
        
        let croppedImage = UIImage(cgImage: cgImage)
        
        guard let imageData = croppedImage.jpegData(compressionQuality: 0.8) else {
            print("Could not convert cropped image to data.")
            return
        }
        print("Trying to upload to Supabase")
        await supabaseManager.updateProfilePicture(imageData: imageData)
    }
}

#Preview {
    EditProfilePictureView()
        .environmentObject(SupabaseManager())
}
