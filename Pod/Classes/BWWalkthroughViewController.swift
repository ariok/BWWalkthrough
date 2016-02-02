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

// MARK: - Protocols -

/**
Walkthrough Delegate:
This delegate performs basic operations such as dismissing the Walkthrough or call whatever action on page change.
Probably the Walkthrough is presented by this delegate.
**/

@objc public protocol BWWalkthroughViewControllerDelegate{
    
    @objc optional func walkthroughCloseButtonPressed()              // If the skipRequest(sender:) action is connected to a button, this function is called when that button is pressed.
    @objc optional func walkthroughNextButtonPressed()               //
    @objc optional func walkthroughPrevButtonPressed()               //
    @objc optional func walkthroughPageDidChange(pageNumber:Int)     // Called when current page changes

}

/** 
Walkthrough Page:
The walkthrough page represents any page added to the Walkthrough.
At the moment it's only used to perform custom animations on didScroll.
**/
@objc public protocol BWWalkthroughPage{
    // While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
    // While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
    // The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
    // This value can be used on the previous, current and next page to perform custom animations on page's subviews.
    
    @objc func walkthroughDidScroll(position:CGFloat, offset:CGFloat)   // Called when the main Scrollview...scrolls
}


@objc public class BWWalkthroughViewController: UIViewController, UIScrollViewDelegate{
    
    // MARK: - Public properties -
    
    weak public var delegate:BWWalkthroughViewControllerDelegate?
    
    // TODO: If you need a page control, next or prev buttons add them via IB and connect them with these Outlets
    @IBOutlet public var pageControl:UIPageControl?
    @IBOutlet public var nextButton:UIButton?
    @IBOutlet public var prevButton:UIButton?
    @IBOutlet public var closeButton:UIButton?
    
    public var currentPage:Int{    // The index of the current page (readonly)
        get{
            let page = Int((scrollview.contentOffset.x / view.bounds.size.width))
            return page
        }
    }
    
    public var currentViewController:UIViewController{ //the controller for the currently visible page
        get{
            let currentPage = self.currentPage;
            return controllers[currentPage];
        }
    }
    
    public var numberOfPages:Int{ //the total number of pages in the walkthrough
        get{
            return self.controllers.count;
        }
    }
    
    
    // MARK: - Private properties -
    
    public let scrollview:UIScrollView!
    private var controllers:[UIViewController]!
    private var lastViewConstraint:NSArray?
    
    
    // MARK: - Overrides -
    
    required public init?(coder aDecoder: NSCoder) {
        // Setup the scrollview
        scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.pagingEnabled = true
        
        // Controllers as empty array
        controllers = Array()
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        scrollview = UIScrollView()
        controllers = Array()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UI Elements
        
        pageControl?.addTarget(self, action: "pageControlDidTouch", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Scrollview
        
        scrollview.delegate = self
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(scrollview, atIndex: 0) //scrollview is inserted as first view of the hierarchy
        
        // Set scrollview related constraints
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview]))
        
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        pageControl?.numberOfPages = controllers.count
        pageControl?.currentPage = 0
    }
    
    
    // MARK: - Internal methods -
    
    /**
     * Progresses to the next page, or calls the finished delegate method if already on the last page
     */
    @IBAction public func nextPage(){
        if (currentPage + 1) < controllers.count {
            
            delegate?.walkthroughNextButtonPressed?()
            gotoPage(currentPage + 1)
        }
    }
    
    @IBAction public func prevPage(){
        
        if currentPage > 0 {
            
            delegate?.walkthroughPrevButtonPressed?()
            gotoPage(currentPage - 1)
        }
    }
    
    // TODO: If you want to implement a "skip" button
    // connect the button to this IBAction and implement the delegate with the skipWalkthrough
    @IBAction public func close(sender: AnyObject){
        delegate?.walkthroughCloseButtonPressed?()
    }
    
    func pageControlDidTouch(){

        if let pc = pageControl{
            gotoPage(pc.currentPage)
        }
    }
    
    private func gotoPage(page:Int){
        
        if page < controllers.count{
            var frame = scrollview.frame
            frame.origin.x = CGFloat(page) * frame.size.width
            scrollview.scrollRectToVisible(frame, animated: true)
        }
    }
    
    /**
    addViewController
    Add a new page to the walkthrough. 
    To have information about the current position of the page in the walkthrough add a UIVIewController which implements BWWalkthroughPage    
    */
    public func addViewController(vc:UIViewController)->Void{
        
        controllers.append(vc)
        
        // Setup the viewController view
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        scrollview.addSubview(vc.view)
        
        // Constraints
        
        let metricDict = ["w":vc.view.bounds.size.width,"h":vc.view.bounds.size.height]
        
        // - Generic cnst
        
        vc.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(h)]", options:[], metrics: metricDict, views: ["view":vc.view]))
        vc.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(w)]", options:[], metrics: metricDict, views: ["view":vc.view]))
        scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]|", options:[], metrics: nil, views: ["view":vc.view,]))
        
        // cnst for position: 1st element
        
        if controllers.count == 1{
            scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]", options:[], metrics: nil, views: ["view":vc.view,]))
            
            // cnst for position: other elements
            
        }else{
            
            let previousVC = controllers[controllers.count-2]
            let previousView = previousVC.view;
            
            scrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previousView]-0-[view]", options:[], metrics: nil, views: ["previousView":previousView,"view":vc.view]))
            
            if let cst = lastViewConstraint{
                scrollview.removeConstraints(cst as! [NSLayoutConstraint])
            }
            lastViewConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[view]-0-|", options:[], metrics: nil, views: ["view":vc.view])
            scrollview.addConstraints(lastViewConstraint! as! [NSLayoutConstraint])
        }
    }

    /** 
    Update the UI to reflect the current walkthrough status
    **/
    
    private func updateUI(){
        
        // Get the current page
        
        pageControl?.currentPage = currentPage
        
        // Notify delegate about the new page
        
        delegate?.walkthroughPageDidChange?(currentPage)
        
        // Hide/Show navigation buttons
        
        if currentPage == controllers.count - 1{
            nextButton?.hidden = true
        }else{
            nextButton?.hidden = false
        }
        
        if currentPage == 0{
            prevButton?.hidden = true
        }else{
            prevButton?.hidden = false
        }
    }
    
    // MARK: - Scrollview Delegate -
    
    public func scrollViewDidScroll(sv: UIScrollView) {
        
        for var i=0; i < controllers.count; i++ {
            
            if let vc = controllers[i] as? BWWalkthroughPage{
            
                let mx = ((scrollview.contentOffset.x + view.bounds.size.width) - (view.bounds.size.width * CGFloat(i))) / view.bounds.size.width
                
                // While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
                // While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
                // The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
                // This value can be used on the previous, current and next page to perform custom animations on page's subviews.
                
                // print the mx value to get more info.
                // println("\(i):\(mx)")
                
                // We animate only the previous, current and next page
                if(mx < 2 && mx > -2.0){
                    vc.walkthroughDidScroll(scrollview.contentOffset.x, offset: mx)
                }
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateUI()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateUI()
    }
    
    /* WIP */
    override public func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("CHANGE")
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("SIZE")
    }
    
}
