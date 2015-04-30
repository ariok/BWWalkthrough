BWWalkthrough 
======================
Version: 0.5 (Swift 1.2 compatible)

Author: Yari D'areglia [@Bitwaker](http://www.twitter.com/bitwaker)


## What is BWWalkthrough?
BWWalkthrough (BWWT) is a class that helps you create **Walkthroughs** for your iOS Apps.
It differs from other similar classes in that there is no rigid template; rigid template; BWWT is just a layer placed over your controllers that gives you complete **freedom on the design of your views.**.

![Preview](http://www.thinkandbuild.it/gifs/BWWalkthrough_mini2.gif)

Video preview [Here](http://vimeo.com/106542773)

The class comes with a set of **pre-built animations** that are automatically applied to the subviews of each page. This set can be  easily substituted with your custom animations.
 
BWWT is essentially defined by 2 classes:
**BWWalkthroughViewController** is the Master (or Container). It shows the walkthrough and contains UI elements that are shared among all the Pages (like UIButtons and UIPageControl).

**BWWalkthroughPageViewController** defines every single Page that is going to be displayed with the walkthrough inside the Master.

## What it's not?
BWWT is not a copy-paste-and-it-just-works class and it is not a fixed walkthrough template. If you need a simple no-configuration walkthrough, BWWT is not the right choice. 

## How to use it?

#### Define the Master

Add a new controller to the Storyboard and set its class as **BWWalkthroughViewController**. This is the Master controller where every page will be attached. 

Here you can add all the elements that have to be visible in all the Pages. 

There are 4 prebuilt IBOutlets that you can attach to your elements to obtain some standard behaviours: UIPageControl (**pageControl**), UIButton to close/skip the walkthrough (**closeButton**) and UIButtons to navigate to the next and the previous page (**nextButton**, **prevButton**).
You can take advantage of these IBOutlets just creating your UI elements and connecting them with the outlets of the Master controller.

#### Define the Pages

Add a new controller to the Storyboard and set it has **BWWalkthroughPageViewController**. Define your views as you prefer. 

#### Attach Pages to the Master

Here is an example that shows how to create a walkthrough reading data from a dedicated Storyboard: 

        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewControllerWithIdentifier("walk0") as! UIViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("walk1") as! UIViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("walk2")as! UIViewController
        let page_three = stb.instantiateViewControllerWithIdentifier("walk3") as! UIViewController
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(page_zero)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)

## Prebuilt Animations 
You can add animations without writing a line of code. You just implement a new Page with its subviews and set an animation style using the runtime argument {Key: **animationType**, type: String} via IB. The BWWalkthrough animates your views depending on the selected animation style.

At the moment (WIP!) the possible value for animationsType are:
**Linear**, **Curve**, **Zoom** and **InOut** 
The speed of the animation on the X and Y axes **must** be modified using the runtime argument {key: **speed** type:CGPoint}, while the runtime argument {key: **speedVariance** type: CGPoint} adds a speed variation to the the subviews of the page depending on the hierarchy position.

**Example**
Let’s say that we have defined these runtime arguments for one of the Pages: 

- animationType: “Linear”
- speed: {0,1} 
- speedVariance: {0,2} 

The subviews of the Page will perform a linear animation adding speed to the upfront elements depending on speedVariance.
So if we have 3 subviews, the speed of each view will be:

- view 0 {0,1+2}
- view 1 {0,1+2+2}
- view 2 {0,1+2+2+2}

creating the ~~infamous~~ parallax effect.

## Custom Animations
Each page of the walkthrough receives information about its normalized offset position implementing the protocol **BWWalkthroughPage**, so you can extend the prebuilt animations adding your super-custom-shiny-woah™ animations depending on this value (here is a simple example)

    func walkthroughDidScroll(position: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/500.0
        
        titleLabel?.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI)*2 * (1.0 - offset), 1, 1, 1)
    }

## Delegate
The **BWWalkthroughViewControllerDelegate** protocol defines some useful methods that you can implement to get more control over the Walkthrough flow. 

    @objc protocol BWWalkthroughViewControllerDelegate {
        @objc optional func walkthroughCloseButtonPressed()
        @objc optional func walkthroughNextButtonPressed()               
        @objc optional func walkthroughPrevButtonPressed()               
        @objc optional func walkthroughPageDidChange(pageNumber:Int)     
    }
