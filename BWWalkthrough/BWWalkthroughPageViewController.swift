/*
The MIT License (MIT)

Copyright (c) 2015 Yari D'areglia @bitwaker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


import UIKit

public enum WalkthroughAnimationType:String{
    case Linear = "Linear"
    case Curve = "Curve"
    case Zoom = "Zoom"
    case InOut = "InOut"
    
    init(_ name:String){
        
        if let tempSelf = WalkthroughAnimationType(rawValue: name){
            self = tempSelf
        }else{
            self = .Linear
        }
    }
}

public class BWWalkthroughPageViewController: UIViewController, BWWalkthroughPage {
    
    private var animation:WalkthroughAnimationType = .Linear
    private var subsWeights:[CGPoint] = Array()
    private var notAnimatableViews:[Int] = [] // Array of views' tags that should not be animated during the scroll/transition
    
    // MARK: Inspectable Properties
    // Edit these values using the Attribute inspector or modify directly the "User defined runtime attributes" in IB
    @IBInspectable var speed:CGPoint = CGPoint(x: 0.0, y: 0.0);            // Note if you set this value via Attribute inspector it can only be an Integer (change it manually via User defined runtime attribute if you need a Float)
    @IBInspectable var speedVariance:CGPoint = CGPoint(x: 0.0, y: 0.0)     // Note if you set this value via Attribute inspector it can only be an Integer (change it manually via User defined runtime attribute if you need a Float)
    @IBInspectable var animationType:String {
        set(value){
            self.animation = WalkthroughAnimationType(rawValue: value)!
        }
        get{
            return self.animation.rawValue
        }
    }
    @IBInspectable var animateAlpha:Bool = false
    @IBInspectable var staticTags:String {                                 // A comma separated list of tags that you don't want to animate during the transition/scroll 
        set(value){
            self.notAnimatableViews = value.componentsSeparatedByString(",").map{Int($0)!}
        }
        get{
            return notAnimatableViews.map{String($0)}.joinWithSeparator(",")
        }
    }
    
    // MARK: BWWalkthroughPage Implementation

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.masksToBounds = true
        subsWeights = Array()
        
        for v in view.subviews{
            speed.x += speedVariance.x
            speed.y += speedVariance.y
            if !notAnimatableViews.contains(v.tag) {
                subsWeights.append(speed)
            }
        }
        
    }
    
    public func walkthroughDidScroll(position: CGFloat, offset: CGFloat) {
        
        for(var i = 0; i < subsWeights.count ;i++){
            
            // Perform Transition/Scale/Rotate animations
            switch animation{
                
            case .Linear:
                animationLinear(i, offset)
                
            case .Zoom:
                animationZoom(i, offset)
                
            case .Curve:
                animationCurve(i, offset)
                
            case .InOut:
                animationInOut(i, offset)
            }
            
            // Animate alpha
            if(animateAlpha){
                animationAlpha(i, offset)
            }
        }
    }

    
    // MARK: Animations (WIP)
    
    private func animationAlpha(index:Int, var _ offset:CGFloat){
        let cView = view.subviews[index] 
        
        if(offset > 1.0){
            offset = 1.0 + (1.0 - offset)
        }
        cView.alpha = (offset)
    }
    
    private func animationCurve(index:Int, _ offset:CGFloat){
        var transform = CATransform3DIdentity
        let x:CGFloat = (1.0 - offset) * 10
        transform = CATransform3DTranslate(transform, (pow(x,3) - (x * 25)) * subsWeights[index].x, (pow(x,3) - (x * 20)) * subsWeights[index].y, 0 )
        applyTransform(index, transform: transform)
    }
    
    private func animationZoom(index:Int, _ offset:CGFloat){
        var transform = CATransform3DIdentity

        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        let scale:CGFloat = (1.0 - tmpOffset)
        transform = CATransform3DScale(transform, 1 - scale , 1 - scale, 1.0)
        applyTransform(index, transform: transform)
    }
    
    private func animationLinear(index:Int, _ offset:CGFloat){
        var transform = CATransform3DIdentity
        let mx:CGFloat = (1.0 - offset) * 100
        transform = CATransform3DTranslate(transform, mx * subsWeights[index].x, mx * subsWeights[index].y, 0 )
        applyTransform(index, transform: transform)
    }
    
    private func animationInOut(index:Int, _ offset:CGFloat){
        var transform = CATransform3DIdentity
        //var x:CGFloat = (1.0 - offset) * 20
        
        var tmpOffset = offset
        if(tmpOffset > 1.0){
            tmpOffset = 1.0 + (1.0 - tmpOffset)
        }
        transform = CATransform3DTranslate(transform, (1.0 - tmpOffset) * subsWeights[index].x * 100, (1.0 - tmpOffset) * subsWeights[index].y * 100, 0)
        applyTransform(index, transform: transform)
    }
    
    private func applyTransform(index:Int, transform:CATransform3D){
        let subview = view.subviews[index]
        if !notAnimatableViews.contains(subview.tag){
            view.subviews[index].layer.transform = transform
        }
    }
    
}