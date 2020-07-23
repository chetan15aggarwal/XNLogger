//
//  XNUIWindow.swift
//  XNLogger
//
//  Created by Sunil Sharma on 22/06/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import UIKit

fileprivate struct XNUITouchEdges {
    
    var top: Bool = false
    var left: Bool = false
    var bottom: Bool = false
    var right: Bool = false
    var center: Bool = false
    
    mutating func reset() {
        top = false
        left = false
        bottom = false
        right = false
        center = false
    }
}

class XNUIWindow: UIWindow {
    
    let windowMinSize: CGSize = CGSize(width: 140, height: 160)
    lazy private var toolBarView: UIView = self.createToolbarView()
    
    private var isMiniModeActive: Bool {
        return XNUIManager.shared.isMiniModeActive
    }
    
    var appWindow: UIWindow? {
        return UIApplication.shared.delegate?.window as? UIWindow
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        if isMiniModeActive {
            return .zero
        } else {
            if #available(iOS 11.0, *) {
                return super.safeAreaInsets
            } else {
                return UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    func present(rootVC: UIViewController) {
        
        self.windowLevel = .init(CGFloat.greatestFiniteMagnitude)
        self.layoutMargins = .zero
        self.backgroundColor = .white
        self.clipsToBounds = true
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = .zero
            self.insetsLayoutMarginsFromSafeArea = false
        }
        self.rootViewController = rootVC
        
        let presentTransition = CATransition()
        presentTransition.duration = 0.37
        presentTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        presentTransition.type = .moveIn
        presentTransition.subtype = .fromTop
        self.layer.add(presentTransition, forKey: kCATransition)
        self.makeKeyAndVisible()
    }
    
    func dismiss() {
        
        self.appWindow?.makeKey()
        var animationDuration: TimeInterval = 0.37
        let isMiniModeActive = self.isMiniModeActive
        
        if isMiniModeActive {
            animationDuration = 0.2
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            if isMiniModeActive {
                self.alpha = 0
            } else {
                self.frame.origin.y = UIScreen.main.bounds.height
                self.alpha = 0.5
            }
        }) { (completed) in
            self.isHidden = true
            self.rootViewController = nil
        }
    }
    
    func enableMiniView() {
        addToolBar()
        var defaultMiniWidth: CGFloat = UIScreen.main.bounds.width * 0.42
        var defaultMiniHeight: CGFloat = UIScreen.main.bounds.height * 0.37
        
        if defaultMiniWidth < windowMinSize.width {
            defaultMiniWidth = windowMinSize.width
        }
        
        if defaultMiniHeight < windowMinSize.height {
            defaultMiniHeight = windowMinSize.height
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear], animations: {
            self.layer.cornerRadius = 10
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            self.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
            self.frame = CGRect(x: UIScreen.main.bounds.width - defaultMiniWidth - 20, y: 90, width: defaultMiniWidth, height: defaultMiniHeight)
        }, completion: nil)
    }
    
    func enableFullScreenView() {
        self.toolBarView.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3) {
            self.layer.cornerRadius = 0
            self.layer.borderWidth = 0
            self.layer.borderColor = nil
            self.transform = .identity
            self.frame = UIScreen.main.bounds
        }
    }
    
    func createToolbarView() -> UIView {
        let toolView = UIView()
        toolView.translatesAutoresizingMaskIntoConstraints = false
        toolView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        let toolStackView = UIStackView()
        toolStackView.axis = .horizontal
        toolStackView.distribution = .fillEqually
        toolStackView.spacing = 1.0
        
        toolStackView.translatesAutoresizingMaskIntoConstraints = false
        toolView.addSubview(toolStackView)
        toolStackView.match(to: toolView, margin: 0)
        
        func toolbarButton(imageName: String, orientation: UIImage.Orientation? = nil) -> UIButton {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .white
            button.imageView?.contentMode = .scaleAspectFit
            var image = UIImage(named: imageName, in: Bundle.current(), compatibleWith: nil)
            if let imgOrientation = orientation, let cgEditImg = image?.cgImage {
                image = UIImage(cgImage: cgEditImg, scale: CGFloat(1), orientation: imgOrientation).withRenderingMode(.alwaysTemplate)
            }
            button.setImage(image, for: .normal)
            return button
        }
        
        let resizeBtn = toolbarButton(imageName: "resize")
        resizeBtn.imageEdgeInsets = UIEdgeInsets(inset: 14)
        let pinchGesture = UIPanGestureRecognizer(target: self, action: #selector(clickedOnResize(_:)))
        resizeBtn.addGestureRecognizer(pinchGesture)
        toolStackView.addArrangedSubview(resizeBtn)
        let moveBtn = toolbarButton(imageName: "move")
        moveBtn.imageEdgeInsets = UIEdgeInsets(inset: 9)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(clickedOnMove(_:)))
        moveBtn.addGestureRecognizer(panGesture)
        toolStackView.addArrangedSubview(moveBtn)
        let moreOptionBtn = toolbarButton(imageName: "menu", orientation: .right)
        moreOptionBtn.imageEdgeInsets = UIEdgeInsets(inset: 11)
        moreOptionBtn.addTarget(self, action: #selector(clickedOnMoreOption(_:)), for: .touchUpInside)
        toolStackView.addArrangedSubview(moreOptionBtn)
        
        let topLineView = UIView()
        topLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        topLineView.autoresizingMask = [.flexibleWidth]
        topLineView.frame.origin.y = 0
        topLineView.frame.size.height = 1
        toolView.addSubview(topLineView)
        
        return toolView
    }
    
    func addToolBar() {
        
        self.addSubview(toolBarView)
        
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        toolBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        toolBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        toolBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        var tabbarHeight: CGFloat = 0
        if let tabbarVC = self.rootViewController as? UITabBarController {
            if #available(iOS 11.0, *) {
                tabbarHeight = tabbarVC.tabBar.frame.height - super.safeAreaInsets.bottom
            } else {
                tabbarHeight = tabbarVC.tabBar.frame.height
            }
        }
        toolBarView.heightAnchor.constraint(equalToConstant: tabbarHeight).isActive = true
        toolBarView.layoutIfNeeded()
    }
    
    @objc func clickedOnResize(_ sender: UIPanGestureRecognizer) {
        guard let appWindow = self.appWindow else { return }
        
        let translation = sender.translation(in: appWindow)
        var newFrame = self.frame
        newFrame.size.height += translation.y
        newFrame.size.width -= translation.x
        newFrame.origin.x += translation.x
        // Check minimum window size
        if newFrame.height < windowMinSize.height {
            newFrame.size.height = windowMinSize.height
        }
        
        if newFrame.width < windowMinSize.width {
            newFrame.origin.x = self.frame.origin.x
            newFrame.size.width = windowMinSize.width
        }
        
        self.frame = newFrame
        sender.setTranslation(.zero, in: appWindow)
    }
    
    @objc func clickedOnMove(_ sender: UIPanGestureRecognizer) {
        guard let appWindow = self.appWindow else { return }
        
        let translation = sender.translation(in: appWindow)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        sender.setTranslation(.zero, in: appWindow)
        
        if sender.state != .ended {
          return
        }

        let velocity = sender.velocity(in: appWindow)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 700
        let slideFactor = 0.05 * slideMultiplier
        var finalPoint = CGPoint(x: self.center.x + (velocity.x * slideFactor),
                                 y: self.center.y + (velocity.y * slideFactor))

        finalPoint.x = min(max(finalPoint.x, 16), appWindow.bounds.width)
        finalPoint.y = min(max(finalPoint.y, 0), appWindow.bounds.height)

        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: {
            self.center = finalPoint
        })
    }
    
    @objc func clickedOnMoreOption(_ sender: UIButton) {
        
         let popoverVC = XNUIPopOverViewController()
        popoverVC.popoverPresentationController?.permittedArrowDirections = [.down]
        var optionItems: [XNUIOptionItem] = [
             XNUIOptionItem(title: "Logs", type: .logsScreen),
             XNUIOptionItem(title: "Settings", type: .settingsScreen)
         ]
        
        if let tabbarVC = self.rootViewController as? UITabBarController, let selectedVC = tabbarVC.selectedViewController {
            
            if let navVC = selectedVC as? UINavigationController, let rootVC = navVC.viewControllers.first, rootVC is XNUILogListVC {
                optionItems[0].isSelected = true
            }
            
            if selectedVC is XNUISettingsVC {
                optionItems[1].isSelected = true
            }
        }
        popoverVC.items = optionItems
        popoverVC.delegate = self
        popoverVC.popoverPresentationController?.sourceView = sender

        self.rootViewController?.present(popoverVC, animated: true, completion: nil)
    }
}

extension XNUIWindow: XNUIPopoverDelegate {
    func popover(_ popover: XNUIPopOverViewController, didSelectItem item: XNUIOptionItem, indexPath: IndexPath) {
        popover.dismiss(animated: false, completion: nil)
        guard let tabbarVC = self.rootViewController as? UITabBarController else { return }
        if item.type == .logsScreen {
            tabbarVC.selectedIndex = 0
        } else if item.type == .settingsScreen {
            tabbarVC.selectedIndex = 1
        }
    }
}
