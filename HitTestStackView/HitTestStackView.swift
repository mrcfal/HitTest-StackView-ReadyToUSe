//
//  HitTestStackView.swift
//  HitTestStackView
//
//  Created by Marco Falanga on 12/07/18.
//  Copyright © 2018 Marco Falanga. All rights reserved.
//

import UIKit

//protocol
protocol HitTestDelegate: class {
    func didSelectIcon(hitTestView: HitTestView)
}

class HitTestView: UIView {
    
    //parentView can add or remove this view as subview (see view in ViewController)
    weak var parentView: UIView? {
        didSet {
            //when this property is set it calls this method
            setupLongGestureRecognizer()
        }
    }
    
    weak var delegate: HitTestDelegate?
    
    var lastImageTouched: UIImage? {
        didSet {
            //everytime the lastImageTouched is set (see longGesture .ended status)
            delegate?.didSelectIcon(hitTestView: self)
        }
    }
    
    var color = UIColor() {
        didSet {
            self.backgroundColor = color
        }
    }
    
    var images = [UIImage]() {
        didSet {
            setupStackView()
        }
    }
    
    var padding: CGFloat = 6 {
        didSet {
            setupStackView()
        }
    }
    var iconHeight: CGFloat = 40 {
        didSet {
            setupStackView()
        }
    }
    
    var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        setupStackView()
    }
    
    fileprivate func setupStackView() {
        let arrangedSubviews = images.map({ (image) -> UIImageView in
            let imageView = UIImageView(image: image)
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = iconHeight/2
            return imageView
        })
        
        stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let numIcons: CGFloat = CGFloat(stackView.subviews.count)
        let width: CGFloat = numIcons * iconHeight + (numIcons + 1) * padding
        
        self.addSubview(stackView)
        self.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)
        stackView.frame = self.frame
        
        self.layer.cornerRadius = self.frame.height/2
        
        self.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLongGestureRecognizer() {
        if let superview = self.parentView {
            setupLongGestureRecognizer(view: superview)
        }
        else {
            print("Error: HitTestView must be a subview")
        }
    }
    
    func setupLongGestureRecognizer(view: UIView) {
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            handleGestureBegan(gesture: gesture, view: gesture.view!)
        }
        else if gesture.state == .ended {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let stackView = self.stackView
                
                stackView.subviews.forEach({ (imageView) in
                    
                    if imageView.transform.isIdentity == false {
                        self.lastImageTouched = (imageView as! UIImageView).image
                    }
                    
                    imageView.transform = .identity
                })
                
                self.transform = self.transform.translatedBy(x: 0, y: self.frame.height)
                self.alpha = 0
                
            }) { _ in
                self.removeFromSuperview()
            }
        }
        else if gesture.state == .changed {
            handleGestureChanged(gesture: gesture)
        }
    }
    
    fileprivate func handleGestureChanged(gesture: UILongPressGestureRecognizer) {
        let pressedLocation = gesture.location(in: self)
        
        //get location in parentView
        let locationInParentView = gesture.location(in: parentView)
        //if location in parentView is before the first item or after the last item, reset the icons and return
        if locationInParentView.x < self.frame.minX || locationInParentView.x > self.frame.maxX {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let stackView = self.stackView
                stackView.subviews.forEach({ (imageView) in
                    imageView.transform = .identity
                })
            }) { _ in
                return
            }
        }
        
        //get location in self but adjust the y value so you are not forced to touch vertically inside the view
        let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.frame.height/2)
        
        let hitTestView = self.hitTest(fixedYLocation, with: nil)
        
        if hitTestView is UIImageView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let stackView = self.stackView
                
                stackView.subviews.forEach({ (imageView) in
                    imageView.transform = .identity
                })
                
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
            }) { _ in
                
            }
        }
    }
    
    fileprivate func handleGestureBegan(gesture: UILongPressGestureRecognizer, view: UIView) {
        view.addSubview(self)
        
        //        let pressedLocation = gesture.location(in: self.view)
        let centeredY = (view.frame.height - self.frame.height)/2
        let centeredX = (view.frame.width - self.frame.width)/2
        //        let valueY = pressedLocation.y - iconsContainerView.frame.height
        let valueY = centeredY - self.frame.height
        
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: centeredX, y: centeredY)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(translationX: centeredX, y: valueY)
        }) { _ in
            
        }
    }
}
