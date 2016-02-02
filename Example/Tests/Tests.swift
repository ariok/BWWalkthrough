import UIKit
import XCTest
import BWWalkthrough

class Tests: XCTestCase {
    
    let walkthrough = BWWalkthroughViewController()
    
    override func setUp() {
        super.setUp()
        walkthrough.addViewController(UIViewController())
        walkthrough.addViewController(UIViewController())
        walkthrough.addViewController(UIViewController())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_walkthroughVC_when_new_controllers_are_added() {
        XCTAssertEqual(walkthrough.numberOfPages, 3, "")
    }
    
}
