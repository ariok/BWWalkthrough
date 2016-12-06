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


/// Walkthrough Delegate:
/// This delegate performs basic operations such as dismissing the Walkthrough or call whatever action on page change.
/// Probably the Walkthrough is presented by this delegate.
@objc public protocol BWWalkthroughViewControllerDelegate{
    
    @objc optional func walkthroughCloseButtonPressed()              // If the skipRequest(sender:) action is connected to a button, this function is called when that button is pressed.
    @objc optional func walkthroughNextButtonPressed()               // Called when the "next page" button is pressed
    @objc optional func walkthroughPrevButtonPressed()               // Called when the "previous page" button is pressed
    @objc optional func walkthroughPageDidChange(_ pageNumber:Int)   // Called when current page changes
}


/// Walkthrough Page:
/// The walkthrough page represents any page added to the Walkthrough.
@objc public protocol BWWalkthroughPage{
    /// While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
    /// While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
    /// The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
    /// This value can be used on the previous, current and next page to perform custom animations on page's subviews.
    @objc func walkthroughDidScroll(to:CGFloat, offset:CGFloat)   // Called when the main Scrollview...scrolls
}


@objc open class BWWalkthroughViewController: UIViewController, UIScrollViewDelegate{
    
    // MARK: - Public properties -
    
    weak open var delegate:BWWalkthroughViewControllerDelegate?
    
    // If you need a page control, next or prev buttons, add them via IB and connect with these Outlets
    @IBOutlet open var pageControl:UIPageControl?
    @IBOutlet open var nextButton:UIButton?
    @IBOutlet open var prevButton:UIButton?
    @IBOutlet open var closeButton:UIButton?
    
    open var currentPage: Int {    // The index of the current page (readonly)
        get{
            let page = Int((scrollview.contentOffset.x / view.bounds.size.width))
            return page
        }
    }
    
    open var currentViewController:UIViewController{ //the controller for the currently visible page
        get{
            let currentPage = self.currentPage;
            return controllers[currentPage];
        }
    }
    
    open var numberOfPages:Int{ //the total number of pages in the walkthrough
        get {
            return self.controllers.count
        }
    }
    
    
    // MARK: - Private properties -
    
    open let scrollview = UIScrollView()
    private var controllers = [UIViewController]()
    private var lastViewConstraint: [NSLayoutConstraint]?
    
    
    // MARK: - Overrides -
    
    required public init?(coder aDecoder: NSCoder) {
        // Setup the scrollview
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.isPagingEnabled = true
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UI Elements
        
        pageControl?.addTarget(self, action: #selector(BWWalkthroughViewController.pageControlDidTouch), for: UIControlEvents.touchUpInside)
        
        // Scrollview
        
        scrollview.delegate = self
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(scrollview, at: 0) //scrollview is inserted as first view of the hierarchy
        
        // Set scrollview related constraints
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview] as [String: UIView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollview]-0-|", options:[], metrics: nil, views: ["scrollview":scrollview] as [String: UIView]))
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        updateUI()
        
        pageControl?.numberOfPages = controllers.count
        pageControl?.currentPage = 0
    }
    
    
    // MARK: - Internal methods -
    
    @IBAction open func nextPage(){
        if (currentPage + 1) < controllers.count {
            
            delegate?.walkthroughNextButtonPressed?()
            gotoPage(currentPage + 1)
        }
    }
    
    @IBAction open func prevPage(){
        if currentPage > 0 {
            
            delegate?.walkthroughPrevButtonPressed?()
            gotoPage(currentPage - 1)
        }
    }
    
    /// If you want to implement a "skip" button
    /// connect the button to this IBAction and implement the delegate with the skipWalkthrough
    @IBAction open func close(_ sender: AnyObject) {
        delegate?.walkthroughCloseButtonPressed?()
    }
    
    func pageControlDidTouch(){
        if let pc = pageControl{
            gotoPage(pc.currentPage)
        }
    }
    
    fileprivate func gotoPage(_ page:Int){
        
        if page < controllers.count{
            var frame = scrollview.frame
            frame.origin.x = CGFloat(page) * frame.size.width
            scrollview.scrollRectToVisible(frame, animated: true)
        }
    }
    
    /// Add a new page to the walkthrough.
    /// To have information about the current position of the page in the walkthrough add a UIVIewController which implements BWWalkthroughPage
    /// - viewController: The view controller that will be added at the end of the view controllers list.
    open func add(viewController:UIViewController)->Void{
        
        controllers.append(viewController)
        
        // Setup the viewController view
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollview.addSubview(viewController.view)
        
        // Constraints
        
        let metricDict = ["w":viewController.view.bounds.size.width,"h":viewController.view.bounds.size.height]
        
        // Generic cnst
        let viewsDict: [String: UIView] = ["view":viewController.view, "container": scrollview]
        
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==container)]", options:[], metrics: metricDict, views: viewsDict))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==container)]", options:[], metrics: metricDict, views: viewsDict))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]|", options:[], metrics: nil, views: viewsDict))
        
        // cnst for position: 1st element
        if controllers.count == 1{
            scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]", options:[], metrics: nil, views: ["view":viewController.view]))
        
        // cnst for position: other elements
        } else {
            
            let previousVC = controllers[controllers.count-2]
            if let previousView = previousVC.view {
                // For this constraint to work, previousView can not be optional
                scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[previousView]-0-[view]", options:[], metrics: nil, views: ["previousView":previousView,"view":viewController.view]))
            }
            
            if let cst = lastViewConstraint {
                scrollview.removeConstraints(cst)
            }
            lastViewConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-0-|", options:[], metrics: nil, views: ["view":viewController.view])
            scrollview.addConstraints(lastViewConstraint!)
        }
    }

    /// Update the UI to reflect the current walkthrough status
    fileprivate func updateUI(){
        
        pageControl?.currentPage = currentPage
        delegate?.walkthroughPageDidChange?(currentPage)
        
        // Hide/Show navigation buttons
        if currentPage == controllers.count - 1{
            nextButton?.isHidden = true
        }else{
            nextButton?.isHidden = false
        }
        
        if currentPage == 0{
            prevButton?.isHidden = true
        }else{
            prevButton?.isHidden = false
        }
    }
    
    // MARK: - Scrollview Delegate -
    
    open func scrollViewDidScroll(_ sv: UIScrollView) {
        
        for i in 0 ..< controllers.count {
            
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
                    vc.walkthroughDidScroll(to:scrollview.contentOffset.x, offset: mx)
                }
            }
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateUI()
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateUI()
    }
    
    fileprivate func adjustOffsetForTransition() {
        
        // Get the current page before the transition occurs, otherwise the new size of content will change the index
        let currentPage = self.currentPage
        
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 0.1 )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            [weak self] in
            self?.gotoPage(currentPage)
        }
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustOffsetForTransition()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustOffsetForTransition()
    }
    
}
