//
//  WalkthroughDelegates.swift
//  Papers3
//
//  Created by James Valaitis on 22/07/2015.
//  Copyright (c) 2015 Mekentosj BV. All rights reserved.
//

import UIKit

//  MARK: BWWalkthroughViewControllerDelegate Protocol

/**
    This delegate performs basic operations such as dismissing the walkthrough or reporting on whatever actions occur with the walkthrough.
 */

@objc protocol BWWalkthroughViewControllerDelegate {
    
    /** Called when the close button is pressed.  */
    @objc optional func walkthroughCloseButtonPressed()
    /** Called when the next button is pressed.  */
    @objc optional func walkthroughNextButtonPressed()
    /** Called when the previous button is pressed.  */
    @objc optional func walkthroughPrevButtonPressed()
    /** Called when the walkthrough page changes for whatever reason.  */
    @objc optional func walkthroughPageDidChange(pageNumber:Int)
    
}

//  MARK: BWWalkthroughPage Protocol

/**
    The walkthrough page represents any page added to the Walkthrough.
    At the moment it's only used to perform custom animations on didScroll.
 */

@objc enum WalkthroughPageControlPreference: Int {
    case Default, ShowCloseButton, HideCloseButton
}

@objc protocol BWWalkthroughPage {
    
    /**
        Called as the scroll view scrolls.
        
        Each page in the walkthrough will be called with it's offset relating to it's position on the screen, and 1.0 will span the width of a page.
        For example, if a page in centred, and you slide to the next page, the offset will go from 1.0 to 2.0, and the page we're sliding to has it's offset change from 0.0 to 1.0.
        Therefore, if you slide to the previous page, the current page's offset changes from 1.0 to 0.0, and the previous page's offset decreases from 2.0 to 1.0.
     */
    @objc func walkthroughDidScroll(position:CGFloat, offset:CGFloat)   // Called when the main Scrollview...scrolls
    
    var delegate: WalkthroughPageDelegate? { get set }
    var pageControlPreference: WalkthroughPageControlPreference { get }
}