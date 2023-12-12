//
//  Shanshihan_Baskaran_FE_8936694UITestsLaunchTests.swift
//  Shanshihan_Baskaran_FE_8936694UITests
//
//  Created by user233228 on 12/7/23.
//

import XCTest

final class Shanshihan_Baskaran_FE_8936694UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
