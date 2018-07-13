//
//  ViewController.swift
//  HitTestStackView
//
//  Created by Marco Falanga on 12/07/18.
//  Copyright © 2018 Marco Falanga. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HitTestDelegate {
    
    //dictionary -> the keys represent the icons in my hitTestView (aka hitTestView.images)
    let myDictionary: [UIImage: String] = [#imageLiteral(resourceName: "check"): "Check icon is tapped", #imageLiteral(resourceName: "cancel"): "Cancel icon is tapped"]
    
    //protocol implementation -> this function is called whenever the longPress is ended (see delegate)
    func didSelectIcon(hitTestView: HitTestView) {
        if let image = hitTestView.lastImageTouched {
            for index in 0..<hitTestView.images.count {
                if image == hitTestView.images[index] {
                    testSelectedIcon = image
                    return
                }
            }
        }
        else {
            testSelectedIcon = nil
        }
    }
    
    //this is where the selected icon is stored, in order to make it readable I just print the value matching the key in myDictionary everytime it changes value
    var testSelectedIcon: UIImage? {
        didSet {
            guard let testSelectedIcon = testSelectedIcon else {
                print("No icon selected")
                return
            }
            print(myDictionary[testSelectedIcon] ?? "No icon in myDictionary")
        }
    }
    
    var test = HitTestView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        test = HitTestView(frame: view.frame)
        test.parentView = view
        test.delegate = self
        //change here the color of you hitTestView
        test.color = .blue
        
        //transform a dictionary into an array of UIImage and set the images property of my HitTestView
        test.images = myDictionary.map({ (key, value) -> UIImage in
            return key
        })
    }
}

