//
//  CustomPageViewController.swift
//  BWWalkthroughExample
//
//  Created by Yari D'areglia on 18/09/14.
//  Copyright (c) 2014 Yari D'areglia. All rights reserved.
//

import UIKit
import BWWalkthrough

class CustomPageViewController: UIViewController, BWWalkthroughPage{

    @IBOutlet var imageView:UIImageView?
    @IBOutlet var titleLabel:UILabel?
    @IBOutlet var textLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("Appearing: \(titleLabel?.text)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Appeared: \(titleLabel?.text)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("Disappearing: \(titleLabel?.text)")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        print("Disappeared: \(titleLabel?.text)")
    }

  
    // MARK: BWWalkThroughPage protocol
    
    func walkthroughDidScroll(to: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/500.0
        
        titleLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(Double.pi) * (1.0 - offset), 1, 1, 1)
        textLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(Double.pi) * (1.0 - offset), 1, 1, 1)
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        imageView?.layer.transform = CATransform3DTranslate(tr, 0 , (1.0 - tmpOffset) * 200, 0)
    }

}
