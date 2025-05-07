//
//  EditProfileImageView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import SwiftUI
import PhotosUI

struct EditProfileImageView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    @State private var loading: Bool = false
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")
    
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                let imgWidth = gr.size.width * 0.75
                let buttonWidth = gr.size.width * 0.93
                ScrollView {
                    VStack {
                        Text("Edit Profile Image")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imgWidth, height: imgWidth)
                            if DataManager.shared.loadingProfileImage {
                                ProgressView()
                                .tint(.red)
                                .controlSize(.large)
                                .padding(.top, 80)
                            }
                        }
                        VStack {
                            ArrowViewButton(title: "Select Image", loading: $loading) {
                                showPicker = true
                            }
                            LoadingButtonView($loading, width: buttonWidth, buttonText: "Delete Profile Image") {
                                // TODO
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(width: buttonWidth, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            DataManager.shared.load([.profileImage]) {
                runOnMainThread {
                    self.image = DataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            runOnMainThread {
                self.loading = true
            }
            return PhotoPicker { selectedImage in
                if let bitmap = imageToBase64String(selectedImage, quality: 0.7) {
                    if DataManager.shared.profileImage == nil || DataManager.shared.profileImage?.playerId != DataManager.shared.player?.id {
                        
                        ProfileImageService.createProfileImage(ProfileImageCreateModel(playerId: DataManager.shared.player?.id ?? -1, image: bitmap)) { _ in
                            
                            DataManager.shared.load(.init([.profileImage]), forceDownloadIfApplicable: true) {
                                runOnMainThread {
                                    self.image = DataManager.shared.profileImage?.uiImage ?? UIImage()
                                    self.loading = true
                                }
                            }
                            
                        } failureCase: { _ in
                            self.loading = false
                            
                        }
                        
                    } else {
                        let prev = DataManager.shared.profileImage!
                        ProfileImageService.updateProfileImage(ProfileImageModel(id: prev.id, playerId: DataManager.shared.player?.id ?? -1, image: bitmap)) { _ in
                            
                            DataManager.shared.load(.init([.profileImage]), forceDownloadIfApplicable: true) {
                                runOnMainThread {
                                    self.image = DataManager.shared.profileImage?.uiImage ?? UIImage()
                                    self.loading = true
                                }
                            }
                            
                            
                        } failureCase: { _ in
                            self.loading = false
                        }
                    }
                    
                } else {
                    AlertManager.shared.showOkAlert("Something Went Wrong!", message: "Unable to convert image to bitmap") {
                        self.loading = false
                    }
                }
            }
        }
    }
    
    func imageToBase64String(_ image: UIImage, quality: CGFloat = 0.7) -> String? {
        guard let jpegData = image.jpegData(compressionQuality: quality) else { return nil }
        return jpegData.base64EncodedString()
    }


}

struct PhotoPicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void

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
        let onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.onImagePicked(uiImage)
                    }
                }
            }
        }
    }
}



#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return EditProfileImageView(_dm: dm)
}
