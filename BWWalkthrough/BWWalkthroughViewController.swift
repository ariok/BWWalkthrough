import UIKit

//  MARK: Walkthrough View Controller
@objc class BWWalkthroughViewController: UIViewController {
    
    //  MARK: Properties - State
    
    /** Index of the current page.  */
    var currentPage: Int {
        get{
            let page = Int((scrollView.contentOffset.x / view.bounds.size.width))
            return page
        }
    }
    /** Object interested in updates to the walkthrough, such as switching pages, or closing it.    */
    weak var delegate: BWWalkthroughViewControllerDelegate?
    /** Title for 'close' button when the end of the walkthrough has been reached.  */
    var finalCloseButtonTitle: String?
    /** The close button title pulled from the storyboard.  */
    private var standardCloseButtonTitle: String?
    private var controllers = [UIViewController]()
    private var lastViewConstraint:NSArray?
    
    //  MARK: Properties - Subviews
    
    @IBOutlet var closeButton:UIButton?
    @IBOutlet var pageControl:UIPageControl?
    @IBOutlet var prevButton:UIButton?
    @IBOutlet var nextButton:UIButton?
    
    /** A scroll view containing the walkthrough pages. */
    let scrollView = UIScrollView()
    
    
    //  MARK: Initialisation
    
    required init(coder aDecoder: NSCoder) {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.keyboardDismissMode = .OnDrag
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UIScrollView
        
        scrollView.delegate = self
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.insertSubview(scrollView, atIndex: 0) //scrollView is inserted as first view of the hierarchy
        
        // Set scrollView related constraints
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[scrollView]-0-|", options:nil, metrics: nil, views: ["scrollView":scrollView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[scrollView]-0-|", options:nil, metrics: nil, views: ["scrollView":scrollView]))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateViewControllers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        pageControl?.numberOfPages = controllers.count
        pageControl?.currentPage = 0
        
        updateButtons()
    }
    
    
    // MARK: - Internal methods -
    
    @IBAction private func nextPage() {
        
        if (currentPage + 1) < controllers.count {
            
            delegate?.walkthroughNextButtonPressed?()
            
            var frame = scrollView.frame
            frame.origin.x = CGFloat(currentPage + 1) * frame.size.width
            scrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    
    @IBAction private func prevPage() {
        
        if currentPage > 0 {
            
            delegate?.walkthroughPrevButtonPressed?()
            
            var frame = scrollView.frame
            frame.origin.x = CGFloat(currentPage - 1) * frame.size.width
            scrollView.scrollRectToVisible(frame, animated: true)
        }
    }
    
    @IBAction private func close(sender: AnyObject){
        delegate?.walkthroughCloseButtonPressed?()
    }
    
    private func updateViewControllers() {
        
        if scrollView.bounds == CGRect.zeroRect {
            return
        }
        
        scrollView.removeConstraints(scrollView.constraints())
        (scrollView.subviews as! [UIView]).map { $0.removeFromSuperview() }
        
        let metrics = ["w": scrollView.bounds.width, "h": scrollView.bounds.height]
        
        for viewControllerIndex in 0..<controllers.count {
            let viewController = controllers[viewControllerIndex]
            let view = viewController.view
            
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.removeHeightWidthConstraints()
            scrollView.addSubview(view)
            
            let viewsDictionary = ["view": view]
            
            //  define height and width
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(h)]", options:nil, metrics: metrics, views: viewsDictionary))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view(w)]", options:nil, metrics: metrics, views: viewsDictionary))
            
            //  define scroll view content size vertically
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:nil, metrics: nil, views: viewsDictionary))
            
            //  position first view at beginning of scroll view
            if viewControllerIndex == 0 {
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]", options:nil, metrics: nil, views: viewsDictionary))
            } else {
                //  position subsequent views after the previous view
                let previousViewController = controllers[viewControllerIndex - 1]
                let previousView = previousViewController.view
                
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previousView][view]", options:nil, metrics: nil, views: ["previousView": previousView, "view": view]))
                
                //  if we added the 'final constraints' before, we remove them
                if let finalConstraints = lastViewConstraint {
                    scrollView.removeConstraints(finalConstraints as [AnyObject])
                }
                
                lastViewConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[view]|", options: nil, metrics: nil, views: viewsDictionary)
                scrollView.addConstraints(lastViewConstraint! as [AnyObject])
            }
        }
        
        view.updateConstraintsIfNeeded()
    }
    
    /**
    addViewController
    Add a new page to the walkthrough.
    To have information about the current position of the page in the walkthrough add a UIVIewController which implements BWWalkthroughPage
    */
    func addViewController(vc:UIViewController)->Void{
        
        controllers.append(vc)
        
        updateViewControllers()
    }
    
    /**
    Update the UI to reflect the current walkthrough situation
    **/
    
    private func updateUI(){
        
        // Get the current page
        
        pageControl?.currentPage = currentPage
        
        // Notify delegate about the new page
        
        delegate?.walkthroughPageDidChange?(currentPage)
        
        // Hide/Show navigation buttons
        
        updateButtons()
    }
    
    /**
    Updates previous and next buttons.
    */
    private func updateButtons() {
        
        if currentPage == controllers.count - 1 {
            nextButton?.hidden = true
        } else {
            nextButton?.hidden = false
        }
        
        if currentPage == 0 {
            prevButton?.hidden = true
        } else {
            prevButton?.hidden = false
        }
        
        if let currentPage = controllers[currentPage] as? BWWalkthroughPage {
            switch currentPage.pageControlPreference {
            case .Default:
                closeButton?.hidden = false
            case .HideCloseButton:
                closeButton?.hidden = true
            case .ShowCloseButton:
                closeButton?.hidden = false
            }
        }
        
        if let finalTitle = finalCloseButtonTitle {
            
            if standardCloseButtonTitle == nil {
                standardCloseButtonTitle = closeButton?.titleLabel?.text
            }
            
            let title = currentPage == controllers.count - 1 ? finalTitle : standardCloseButtonTitle
            closeButton?.setTitle(title, forState: .Normal)
        }
    }
    
    // MARK: - Scrollview Delegate -
    
    
    
    
    /* WIP */
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        println("CHANGE")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        println("SIZE")
    }
}

//  MARK: UIScrollViewDelegate Methods
extension BWWalkthroughViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(sv: UIScrollView) {
        
        for var i=0; i < controllers.count; i++ {
            
            if let vc = controllers[i] as? BWWalkthroughPage{
                
                let mx = ((scrollView.contentOffset.x + view.bounds.size.width) - (view.bounds.size.width * CGFloat(i))) / view.bounds.size.width
                
                // While sliding to the "next" slide (from right to left), the "current" slide changes its offset from 1.0 to 2.0 while the "next" slide changes it from 0.0 to 1.0
                // While sliding to the "previous" slide (left to right), the current slide changes its offset from 1.0 to 0.0 while the "previous" slide changes it from 2.0 to 1.0
                // The other pages update their offsets whith values like 2.0, 3.0, -2.0... depending on their positions and on the status of the walkthrough
                // This value can be used on the previous, current and next page to perform custom animations on page's subviews.
                
                // print the mx value to get more info.
                // println("\(i):\(mx)")
                
                // We animate only the previous, current and next page
                if(mx < 2 && mx > -2.0){
                    vc.walkthroughDidScroll(scrollView.contentOffset.x, offset: mx)
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateUI()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateUI()
    }
}

extension BWWalkthroughViewController: WalkthroughPageDelegate {
    func walkthroughPageRequestPageControlPreferenceRefresh(walkthroughPage: BWWalkthroughPage) {
        updateButtons()
    }
    
    func walkthroughPageRequestsDismissal(walkthroughPage: BWWalkthroughPage) {
        close(self)
    }
}

extension UIView {
    func removeHeightWidthConstraints() {
        for constraint in constraints() as! [NSLayoutConstraint] {
            if constraint.firstAttribute == .Width || constraint.secondAttribute == .Width ||
                constraint.firstAttribute == .Height || constraint.secondAttribute == .Height {
                    removeConstraint(constraint)
            }
        }
    }
}
