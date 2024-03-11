//
//  BlendProcessor.swift

import UIKit
import Combine
import Vision
import CoreImage.CIFilterBuiltins

class BlendProcessor {
    static let shared = BlendProcessor()
    var photoOutput = UIImage()
    let context = CIContext()
    let request = VNGeneratePersonSegmentationRequest()
    
    func generateBlend(backImage: UIImage, foreImage: UIImage) {
        guard
            let backgroundImage = backImage.cgImage,
            let foregroundImage = foreImage.cgImage else {
            print("Missing required images")
            return
        }
        
        // Create request
        request.qualityLevel = .accurate
        request.revision = VNGeneratePersonSegmentationRequestRevision1
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        // Create request handler
        let requestHandler = VNImageRequestHandler(
            cgImage: foregroundImage,
            options: [:])
        
        do {
            // Process request
            try requestHandler.perform([request])
            guard let mask = request.results?.first else {
                print("Error generating person segmentation mask")
                return
            }
            
            let foreground = CIImage(cgImage: foregroundImage)
            let maskImage = CIImage(cvPixelBuffer: mask.pixelBuffer)
            let background = CIImage(cgImage: backgroundImage)
            
            guard let output = blendImages(
                background: background,
                foreground: foreground,
                mask: maskImage) else {
                print("Error blending images")
                return
            }
            
            // Update photoOutput
            if let photoResult = renderAsUIImage(output) {
                self.photoOutput = photoResult
            }
        } catch {
            print("Error processing person segmentation request")
        }
    }
    
    func blendImages(
        background: CIImage,
        foreground: CIImage,
        mask: CIImage
    ) -> CIImage? {
        // scale mask
        let maskScaleX = foreground.extent.width / mask.extent.width
        let maskScaleY = foreground.extent.height / mask.extent.height
        let maskScaled = mask.transformed(by: __CGAffineTransformMake(maskScaleX, 0, 0, maskScaleY, 0, 0))
        
        // scale background
        let backgroundScaleX = (foreground.extent.width / background.extent.width)
        let backgroundScaleY = (foreground.extent.height / background.extent.height)
        let backgroundScaled = background.transformed(
            by: __CGAffineTransformMake(backgroundScaleX, 0, 0, backgroundScaleY, 0, 0))
        
        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = foreground
        blendFilter.backgroundImage = backgroundScaled
        blendFilter.maskImage = maskScaled
        
        //     return blendFilter.outputImage?.oriented(.right)
        return blendFilter.outputImage
    }
    
    private func renderAsUIImage(_ image: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// Source
// https://developer.apple.com/documentation/vision/applying_matte_effects_to_people_in_images_and_video
// https://www.raywenderlich.com/29650263-person-segmentation-in-the-vision-framework

