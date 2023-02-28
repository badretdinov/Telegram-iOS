import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import AppBundle
import SemanticStatusNode
import AnimationUI

private func generateImage(imageSize: CGSize, textFrame: CGRect, str: NSAttributedString) -> UIImage {
    UIGraphicsImageRenderer(size: imageSize).image { context in
        str.draw(in: textFrame)
    }
}

private func invertMask(_ image: UIImage) -> UIImage?
{
    guard let inputMaskImage = CIImage(image: image),
          let backgroundImageFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor.black]),
          let inputColorFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor.clear]),
        let inputImage = inputColorFilter.outputImage,
        let backgroundImage = backgroundImageFilter.outputImage,
          let filter = CIFilter(name: "CIBlendWithAlphaMask", parameters: [kCIInputImageKey: inputImage, kCIInputBackgroundImageKey: backgroundImage, kCIInputMaskImageKey: inputMaskImage]),
        let filterOutput = filter.outputImage,
        let outputImage = CIContext().createCGImage(filterOutput, from: inputMaskImage.extent) else { return nil }
    let finalOutputImage = UIImage(cgImage: outputImage)
    return finalOutputImage
}

final class CallControllerRatingCloseButtonNode: ASButtonNode {
    private var currentSize: CGSize?
    
    private let progressNode: ASDisplayNode
    private let textContainerNode: ASDisplayNode
    private let textNode: ASTextNode
    
    private let effectView: UIVisualEffectView
    
    private let maskLayer = CALayer()
    
    var timeOutAction: (()->Void)?
    
    init(
        text: String
    ) {
        self.progressNode = ASDisplayNode()
        self.textContainerNode = ASDisplayNode()
        self.textNode = ASTextNode()
        
        self.effectView = UIVisualEffectView()
        
        super.init()
        
        self.view.addSubview(self.effectView)
        self.addSubnode(self.textContainerNode)
        self.textContainerNode.addSubnode(self.textNode)
        self.addSubnode(self.progressNode)
        
        self.effectView.effect = UIBlurEffect(style: .light)
        
        self.progressNode.layer.mask = self.maskLayer
        self.textContainerNode.clipsToBounds = true
        
        self.layer.cornerRadius = 14
        
        self.progressNode.backgroundColor = .white
        self.progressNode.cornerRadius = 10
        
        self.textNode.attributedText = NSAttributedString(string: text, font: Font.semibold(17.0), textColor: .white)
        self.textNode.clipsToBounds = true
        
        self.textNode.isUserInteractionEnabled = false
        self.textContainerNode.isUserInteractionEnabled = false
        self.effectView.isUserInteractionEnabled = false
        self.progressNode.isUserInteractionEnabled = false
    }
    
    func updateLayout(size: CGSize) -> CGSize {
        self.currentSize = size
        self.effectView.frame = CGRect(origin: .zero, size: size)
        self.progressNode.frame = CGRect(origin: .zero, size: size)
        self.textContainerNode.frame = CGRect(origin: .zero, size: size)
        let textSize = self.textNode.updateLayout(size)
        self.textNode.frame = CGRect(origin: CGPoint(x: (size.width - textSize.width)/2, y: (size.height - textSize.height)/2), size: textSize)
        
        let img = generateImage(imageSize: size, textFrame: self.textNode.frame, str: self.textNode.attributedText ?? .init())
        
        self.maskLayer.frame = .init(origin: .zero, size: size)
        self.maskLayer.contents = invertMask(img)?.cgImage
        
        return size
    }
    
    func animateIn(fromRect: CGRect, textColor: UIColor) {
        guard let size = self.currentSize else {
            return
        }
        
        self.progressNode.isHidden = true
        self.effectView.isHidden = true
        self.textNode.isHidden = true
        
        let animatableNode = ASDisplayNode()
        animatableNode.backgroundColor = .white
        animatableNode.layer.cornerRadius = 14
        animatableNode.clipsToBounds = true
        let textNode = ASTextNode()
        self.addSubnode(animatableNode)
        animatableNode.addSubnode(textNode)
        
        textNode.attributedText = NSAttributedString(string: self.textNode.attributedText?.string ?? "", font: Font.semibold(17.0), textColor: textColor)
        let textSize = textNode.updateLayout(self.bounds.size)
        
        animatableNode.frame = self.bounds
        textNode.frame = CGRect(origin: CGPoint(x: (size.width - textSize.width)/2, y: (size.height - textSize.height)/2), size: textSize)
        
        animatableNode.layer.animateFrame(from: fromRect, to: animatableNode.frame, duration: 0.3, removeOnCompletion: false)
        animatableNode.layer.animateKeyframes(values: [fromRect.height/2, 14] as [NSNumber], duration: 0.3, keyPath: "cornerRadius", removeOnCompletion: false)
        animatableNode.layer.animateKeyframes(values: [UIColor.red.cgColor, UIColor.white.cgColor], duration: 0.3, keyPath: "backgroundColor", removeOnCompletion: false)
        var fromPosition = textNode.position
        fromPosition.x -= animatableNode.frame.width - fromRect.width
        textNode.layer.animatePosition(from: fromPosition, to: textNode.position, duration: 0.3, completion: { [weak self] _ in
            animatableNode.removeFromSupernode()
            
            self?.clipsToBounds = true
            self?.progressNode.isHidden = false
            self?.effectView.isHidden = false
            self?.textNode.isHidden = false
            self?.startCountdown()
        })
    }
    
    private func startCountdown() {
        guard let size = currentSize else {
            return
        }
        
        self.progressNode.layer.animateFrame(from: self.progressNode.frame, to: CGRect(x: size.width, y: 0, width: 0, height: size.height), duration: 5.0, timingFunction: CAMediaTimingFunctionName.linear.rawValue, removeOnCompletion: false, completion: { [weak self] _ in
            self?.timeOutAction?()
        })

        var toFrame = self.maskLayer.frame
        toFrame.origin.x -= size.width
        self.maskLayer.animateFrame(from: self.maskLayer.frame, to: toFrame, duration: 5, timingFunction: CAMediaTimingFunctionName.linear.rawValue, removeOnCompletion: false)
        
        self.textContainerNode.layer.animateFrame(from: CGRect(x: 0, y: 0, width: 0, height: size.height), to: CGRect(x: 0, y: 0, width: size.width, height: size.height), duration: 5.0, timingFunction: CAMediaTimingFunctionName.linear.rawValue, removeOnCompletion: false)
    }
}
