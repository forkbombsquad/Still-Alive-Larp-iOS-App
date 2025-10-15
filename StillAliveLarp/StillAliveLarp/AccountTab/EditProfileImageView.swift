//
//  EditProfileImageView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import SwiftUI
import PhotosUI

struct EditProfileImageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State private var loading: Bool = false
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")
    
    @State private var showPicker = false
    
    @State private var selectImageText: String? = "Select Image"
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                let imgWidth = gr.size.width * 0.75
                let buttonWidth = gr.size.width * 0.93
                ScrollView {
                    VStack {
                        LoadingLayoutView {
                            VStack {
                                if let player = DM.getCurrentPlayer() {
                                    globalCreateTitleView("Edit Profile Image", DM: DM)
                                    ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: imgWidth, height: imgWidth)
                                        if loading {
                                            ProgressView()
                                            .tint(.red)
                                            .controlSize(.large)
                                            .padding(.top, 80)
                                        }
                                    }
                                    VStack {
                                        ArrowViewButton(bindingTitle: $selectImageText, loading: $loading) {
                                            showPicker = true
                                        }
                                        if player.profileImage != nil {
                                            LoadingButtonView($loading, width: buttonWidth, buttonText: "Delete Profile Image") {
                                                self.loading = true
                                                self.selectImageText = "Deleting Profile Image..."
                                                ProfileImageService.deleteProfileImage(player.id) { _ in
                                                    runOnMainThread {
                                                        self.image = UIImage(imageLiteralResourceName: "blank-profile")
                                                        alertManager.showSuccessAlert("Profile Image Deleted!") {}
                                                        DM.load()
                                                        self.loading = false
                                                        self.selectImageText = "Select Image"
                                                    }
                                                } failureCase: { error in
                                                    runOnMainThread {
                                                        self.loading = false
                                                    }
                                                }

                                            }.padding(.horizontal, 8)
                                        }
                                    }
                                    .frame(width: buttonWidth, alignment: .center)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .sheet(isPresented: $showPicker) {
            runOnMainThread {
                self.loading = true
            }
            return PhotoPicker { selectedImage in
                guard let selectedImage = selectedImage else {
                    runOnMainThread {
                        self.loading = false
                        self.selectImageText = "Select Image"
                    }
                    return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    runOnMainThread {
                        self.loading = true
                        self.selectImageText = "Compressing Image..."
                    }
                    if let bitmap = imageToBase64String(selectedImage, quality: 0.7) {
                        if let player = DM.getCurrentPlayer() {
                            runOnMainThread {
                                self.selectImageText = "Preparing Image For Upload..."
                            }
                            if let previousImage = player.profileImage { // Update
                                let updatedImage = ProfileImageModel(id: previousImage.id, playerId: player.id, image: bitmap)
                                
                                runOnMainThread {
                                    self.image = updatedImage.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                                    self.selectImageText = "Uploading Image..."
                                }
                                
                                ProfileImageService.updateProfileImage(updatedImage) { _ in
                                    
                                    runOnMainThread {
                                        DM.load()
                                        self.loading = false
                                        self.selectImageText = "Select Image"
                                    }
                                    
                                } failureCase: { _ in
                                    runOnMainThread {
                                        self.loading = false
                                        self.selectImageText = "Select Image"
                                    }
                                }
                                
                            } else { // Create
                                let createModel = ProfileImageCreateModel(playerId: player.id, image: bitmap)
                                
                                runOnMainThread {
                                    self.image = createModel.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                                    self.selectImageText = "Uploading Image..."
                                }
                                
                                ProfileImageService.createProfileImage(createModel) { _ in
                                    runOnMainThread {
                                        DM.load()
                                        self.loading = false
                                        self.selectImageText = "Select Image"
                                    }
                                    
                                } failureCase: { _ in
                                    runOnMainThread {
                                        self.selectImageText = "Select Image"
                                        self.loading = false
                                    }
                                }
                                
                            }
                        } else {
                            alertManager.showOkAlert("Something Went Wrong!", message: "Player not found!") {
                                runOnMainThread {
                                    self.selectImageText = "Select Image"
                                    self.loading = false
                                }
                            }
                        }
                    } else {
                        alertManager.showOkAlert("Something Went Wrong!", message: "Unable to convert image to bitmap") {
                            runOnMainThread {
                                self.selectImageText = "Select Image"
                                self.loading = false
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { // Custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if loading || DM.isLoadingMirror {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        runOnMainThread {
                            alertManager.showOkAlert("Cannot Go Back Yet!", message: "Your new profile image is still uploading. Please wait for it to finish.") { }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }

    }
    
    func displayFinishedMessage() {
        alertManager.showSuccessAlert("Profile Image Updated!") {}
        runOnMainThread {
            self.selectImageText = "Select Image"
        }
    }
    
    func imageToBase64String(_ image: UIImage, quality: CGFloat = 0.7) -> String? {
        guard let jpegData = image.jpegData(compressionQuality: quality) else { return nil }
        return jpegData.base64EncodedString()
    }


}

struct PhotoPicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagePicked: (UIImage?) -> Void

        init(onImagePicked: @escaping (UIImage?) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { img, err in
                DispatchQueue.main.async {
                    self.onImagePicked(img as? UIImage)
                }
            }
        }
    }
}



//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return EditProfileImageView()
//}
