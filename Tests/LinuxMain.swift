import XCTest

import MockedTests

var tests = [XCTestCaseEntry]()
tests += MockedTests.allTests()
XCTMain(tests)
