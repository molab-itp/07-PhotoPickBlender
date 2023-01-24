//
//  PhotoPicker.swift

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
  @Binding var pickerResult: [UIImage]
  @Binding var isPresented: Bool
  var limit = 1
  
  func makeUIViewController(context: Context) -> some UIViewController {
    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    configuration.filter = .images // filter only to images
    configuration.selectionLimit = limit
    
    let photoPickerViewController = PHPickerViewController(configuration: configuration)
    photoPickerViewController.delegate = context.coordinator
    return photoPickerViewController
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: PHPickerViewControllerDelegate {
    private let parent: PhotoPicker
    
    init(_ parent: PhotoPicker) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      parent.pickerResult.removeAll()
      
      for image in results {
        
        show_meta(image)
        
        if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
          image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] newImage, error in
            if let error = error {
              print("Can't load image \(error.localizedDescription)")
            } else if let image = newImage as? UIImage {
              self?.parent.pickerResult.append(image)
            }
          }
        } else {
          print("Can't load asset")
        }
      }
      
      parent.isPresented = false
    }
  }
}

// Display location and creation date meta data for a photo result
func show_meta(_ image: PHPickerResult) {
  if image.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
    image.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
      guard let data = data,
            let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil) else { return }
            
      let dict:NSDictionary = properties as NSDictionary;
      
      if let val = dict[kCGImagePropertyGPSDictionary] {
        if let gps = val as? NSDictionary {
          if let lat = gps["Latitude"] {
            print("Latitude", lat)
          }
          if let lon = gps["Longitude"] {
            print("Longitude", lon)
          }
        }
      }

      if let val = dict[kCGImagePropertyExifDictionary] {
        if let exif = val as? NSDictionary {
          if let ddate = exif["DateTimeOriginal"] {
            print("ddate", ddate)
          }
        }
      }
    }
  }
}

// https://developer.apple.com/videos/play/wwdc2020/10652/
// Meet the new Photos picker

// https://developer.apple.com/documentation/photokit/selecting_photos_and_videos_in_ios
// Selecting Photos and Videos in iOS
// Load Asset Metadata

// https://developer.apple.com/forums/thread/654898
// How to obtain photo data/metadata after being picked in PHPickerViewController?

