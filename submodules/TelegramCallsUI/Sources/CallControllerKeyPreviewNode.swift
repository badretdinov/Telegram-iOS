import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import LegacyComponents

final class CallControllerKeyPreviewNode: ASDisplayNode {
    private let keyTextNode: ASTextNode
    private let titleTextNode: ASTextNode
    private let infoTextNode: ASTextNode
    private let buttonNode: ASButtonNode
    private let separatorNode: ASDisplayNode
    
    private let effectView: UIVisualEffectView
    
    private let dismiss: () -> Void
    
    init(keyText: String, titleText: String, infoText: String, buttonText: String, dismiss: @escaping () -> Void) {
        self.keyTextNode = ASTextNode()
        self.keyTextNode.displaysAsynchronously = false
        self.infoTextNode = ASTextNode()
        self.infoTextNode.displaysAsynchronously = false
        self.titleTextNode = ASTextNode()
        self.titleTextNode.displaysAsynchronously = false
        self.dismiss = dismiss
        self.separatorNode = ASDisplayNode()
        self.separatorNode.displaysAsynchronously = false
        self.buttonNode = ASButtonNode()
        self.buttonNode.displaysAsynchronously = false
        
        self.effectView = UIVisualEffectView()
        self.effectView.layer.cornerRadius = 20
        self.effectView.clipsToBounds = true
        if #available(iOS 9.0, *) {
        } else {
            self.effectView.effect = UIBlurEffect(style: .light)
            self.effectView.alpha = 0.0
        }
        
        super.init()
        
        self.keyTextNode.attributedText = NSAttributedString(string: keyText, attributes: [NSAttributedString.Key.font: Font.regular(48.0), NSAttributedString.Key.kern: 11.0 as NSNumber])
        
        self.titleTextNode.attributedText = NSAttributedString(string: titleText, font: Font.semibold(16.0), textColor: UIColor.white, paragraphAlignment: .center)
        
        self.infoTextNode.attributedText = NSAttributedString(string: infoText, font: Font.regular(16.0), textColor: UIColor.white, paragraphAlignment: .center)
        
        self.separatorNode.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        self.buttonNode.setAttributedTitle(NSAttributedString(string: buttonText, font: Font.regular(20.0), textColor: UIColor.white, paragraphAlignment: .center), for: .normal)
        
        self.view.addSubview(self.effectView)
        self.addSubnode(self.keyTextNode)
        self.addSubnode(self.titleTextNode)
        self.addSubnode(self.infoTextNode)
        self.addSubnode(self.separatorNode)
        self.addSubnode(self.buttonNode)
        
        self.buttonNode.addTarget(self, action: #selector(self.handleTap), forControlEvents: .touchUpInside)
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:))))
    }
    
    func updateLayout(size: CGSize, transition: ContainedViewLayoutTransition) -> CGSize {
        let width: CGFloat = 304
        
        var originY: CGFloat = 20
        
        let keyTextSize = self.keyTextNode.measure(CGSize(width: width, height: size.height))
        transition.updateFrame(node: self.keyTextNode, frame: CGRect(origin: CGPoint(x: floor((width - keyTextSize.width) / 2) + 6.0, y: originY), size: keyTextSize))
        originY += keyTextSize.height + 10
                               
        let titleTextSize = self.titleTextNode.measure(CGSize(width: width - 32.0, height: CGFloat.greatestFiniteMagnitude))
        transition.updateFrame(node: self.titleTextNode, frame: CGRect(origin: CGPoint(x: floor((width - titleTextSize.width) / 2.0), y: originY), size: titleTextSize))
        originY += titleTextSize.height + 10
        
        let infoTextSize = self.infoTextNode.measure(CGSize(width: width - 32.0, height: CGFloat.greatestFiniteMagnitude))
        transition.updateFrame(node: self.infoTextNode, frame: CGRect(origin: CGPoint(x: floor((width - infoTextSize.width) / 2.0), y: originY), size: infoTextSize))
        originY += infoTextSize.height + 19
        
        transition.updateFrame(node: self.separatorNode, frame: CGRect(x: 0, y: originY, width: width, height: 1))
        originY += 1
        
        transition.updateFrame(node: self.buttonNode, frame: CGRect(x: 0, y: originY, width: width, height: 44))
        originY += 44
        
        self.effectView.frame = CGRect(origin: CGPoint(), size: .init(width: width, height: originY))
        
        return CGSize(width: width, height: originY)
    }
    
    func animateIn(fromNode: ASDisplayNode) {
        let rect = convert(fromNode.bounds, from: fromNode)
        let scale = rect.size.width / self.keyTextNode.frame.size.width
        
        self.keyTextNode.layer.animatePosition(from: CGPoint(x: rect.midX, y: rect.midY), to: self.keyTextNode.layer.position, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        if let transitionView = fromNode.view.snapshotView(afterScreenUpdates: false) {
            self.view.addSubview(transitionView)
            transitionView.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, removeOnCompletion: false)
            transitionView.layer.animatePosition(from: CGPoint(x: rect.midX, y: rect.midY), to: self.keyTextNode.layer.position, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false, completion: { [weak transitionView] _ in
                transitionView?.removeFromSuperview()
            })
            transitionView.layer.animateScale(from: 1.0, to: self.keyTextNode.frame.size.width / rect.size.width, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false)
        }
        self.keyTextNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.15)
        self.keyTextNode.layer.animateScale(from: scale, to: 1.0, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        
        for node in [self.infoTextNode, self.titleTextNode, self.separatorNode, self.buttonNode] {
            node.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.3)
            node.layer.animateScale(from: scale, to: 1.0, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
            let infoYDiff = (node.frame.midY - self.keyTextNode.frame.midY) * scale
            node.layer.animatePosition(from: CGPoint(x: rect.midX, y: rect.midY + infoYDiff), to: node.layer.position, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        }
        
        self.effectView.layer.animateScale(from: scale, to: 1.0, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        let effectYDiff = (self.effectView.frame.midY - self.keyTextNode.frame.midY) * scale
        self.effectView.layer.animatePosition(from: CGPoint(x: rect.midX, y: rect.midY + effectYDiff), to: self.effectView.layer.position, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        
        UIView.animate(withDuration: 0.3, animations: {
            if #available(iOS 9.0, *) {
                self.effectView.effect = UIBlurEffect(style: .light)
            } else {
                self.effectView.alpha = 1.0
            }
        })
    }
    
    func animateOut(toNode: ASDisplayNode, completion: @escaping () -> Void) {
        let rect = convert(toNode.bounds, from: toNode)
        let scale = rect.size.width / self.keyTextNode.frame.size.width
        
        self.keyTextNode.layer.animatePosition(from: self.keyTextNode.layer.position, to: CGPoint(x: rect.midX + 2.0, y: rect.midY), duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false, completion: { _ in
            completion()
        })
        self.keyTextNode.layer.animateScale(from: 1.0, to: rect.size.width / (self.keyTextNode.frame.size.width - 2.0), duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false)
        
        for node in [self.infoTextNode, self.titleTextNode, self.separatorNode, self.buttonNode] {
            node.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3, removeOnCompletion: false)
            node.layer.animateScale(from: 1.0, to: scale, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false)
            let infoYDiff = (node.frame.midY - self.keyTextNode.frame.midY) * scale
            node.layer.animatePosition(from: node.layer.position, to: CGPoint(x: rect.midX, y: rect.midY + infoYDiff), duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        }
        
        self.effectView.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3, removeOnCompletion: false)
        self.effectView.layer.animateScale(from: 1.0, to: scale, duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: false)
        let effectYDiff = (self.effectView.frame.midY - self.keyTextNode.frame.midY) * scale
        self.effectView.layer.animatePosition(from: self.effectView.layer.position, to: CGPoint(x: rect.midX, y: rect.midY + effectYDiff), duration: 0.3, timingFunction: kCAMediaTimingFunctionSpring)
        
        UIView.animate(withDuration: 0.3, animations: {
            if #available(iOS 9.0, *) {
                self.effectView.effect = nil
            } else {
                self.effectView.alpha = 0.0
            }
        })
    }
    
    //MARK: Remove later?
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.dismiss()
        }
    }
    
    @objc private func handleTap() {
        self.dismiss()
    }
}

