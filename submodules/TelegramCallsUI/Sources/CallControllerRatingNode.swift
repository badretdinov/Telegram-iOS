import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import AppBundle
import SemanticStatusNode
import AnimationUI

private class CallControllerRatingButtonNode: ASButtonNode {
    let value: Int
    
    init(
        value: Int
    ) {
        self.value = value
        
        super.init()
        
        self.setImage(UIImage(bundleImageName: "Call/Star2"), for: .normal)
        self.setImage(UIImage(bundleImageName: "Call/StarHighlighted2"), for: .selected)
    }
    
    @objc func blink() {
        self.layer.animateKeyframes(values: [1.0, 1.2, 1.0] as [NSNumber], duration: 0.3, keyPath: "transform.scale")
    }
}

private class CallControllerRatingButtonsContainerNode: ASDisplayNode {
    private let buttonNodes: [CallControllerRatingButtonNode]
    
    var didSelect: ((Int)->Void)?
    
    override init() {
        self.buttonNodes = (0..<5).map({ index in
            CallControllerRatingButtonNode(value: index)
        })
        
        super.init()
        
        self.buttonNodes.forEach { button in
            self.addSubnode(button)
            button.addTarget(self, action: #selector(self.handleButtonTap(_:)), forControlEvents: .touchUpInside)
        }
    }
    
    func updateLayout() -> CGSize {
        var width: CGFloat = -4
        let height: CGFloat = 42
        
        for buttonNode in buttonNodes {
            width += 4
            buttonNode.frame = CGRect(x: width, y: 0, width: 42, height: 42)
            width += 42
        }
        
        return CGSize(width: width, height: height)
    }
    
    @objc private func handleButtonTap(_ button: CallControllerRatingButtonNode) {
        for buttonNode in buttonNodes where buttonNode.value <= button.value {
            buttonNode.isSelected = true
            buttonNode.blink()
        }
        
        self.didSelect?(button.value + 1)
    }
}

final class CallControllerRatingNode: ASDisplayNode {
    private var layout: CGSize?
    
    private let effectView: UIVisualEffectView
    private let titleNode: ASTextNode
    private let descriptionNode: ASTextNode
    private let buttonsContainer: CallControllerRatingButtonsContainerNode
    
    var didSelectRating: ((Int)->Void)?
    
    init(
        title: String,
        description: String
    ) {
        self.effectView = UIVisualEffectView()
        self.titleNode = ASTextNode()
        self.descriptionNode = ASTextNode()
        self.buttonsContainer = CallControllerRatingButtonsContainerNode()
        
        super.init()
        
        self.view.addSubview(self.effectView)
        self.addSubnode(self.titleNode)
        self.addSubnode(self.descriptionNode)
        self.addSubnode(self.buttonsContainer)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.effectView.effect = UIBlurEffect(style: .light)
        
        self.titleNode.attributedText = NSAttributedString(string: title, font: Font.semibold(16.0), textColor: .white)
        self.descriptionNode.attributedText = NSAttributedString(string: description, font: Font.regular(16.0), textColor: .white)
        self.descriptionNode.maximumNumberOfLines = 0
        
        self.buttonsContainer.didSelect = { [weak self] rating in
            self?.didSelectRating?(rating)
        }
    }
    
    func updateLayout(width: CGFloat) -> CGSize {
        var originY: CGFloat = 20
        
        let titleSize = self.titleNode.updateLayout(CGSize(width: width - 32, height: 100))
        self.titleNode.frame = CGRect(x: (width - titleSize.width)/2, y: originY, width: titleSize.width, height: titleSize.height)
        originY += titleSize.height + 10
        
        let descriptionSize = self.descriptionNode.updateLayout(CGSize(width: width - 32, height: .greatestFiniteMagnitude))
        self.descriptionNode.frame = CGRect(x: (width - descriptionSize.width)/2, y: originY, width: descriptionSize.width, height: descriptionSize.height)
        originY += descriptionSize.height + 10
        
        let buttonsSize = self.buttonsContainer.updateLayout()
        self.buttonsContainer.frame = CGRect(x: (width - buttonsSize.width)/2, y: originY, width: buttonsSize.width, height: buttonsSize.height)
        originY += buttonsSize.height + 20
        
        self.effectView.frame = CGRect(x: 0, y: 0, width: width, height: originY)
        
        return CGSize(width: width, height: originY)
    }
    
    func animateIn() {
        self.layer.animateScale(from: 0.5, to: 1.0, duration: 0.3)
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
    }
}
