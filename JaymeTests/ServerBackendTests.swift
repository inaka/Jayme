// Jayme
// ServerBackendTests.swift
//
// Copyright (c) 2016 Inaka - http://inaka.net/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import Jayme

class ServerBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
}

// MARK: - Tests

extension ServerBackendTests {
    
    func testBadURL() {
        let configuration = ServerBackendConfiguration(basePath: "http://próblematiç_url", httpHeaders: [])
        let backend = ServerBackend(configuration: configuration)
        let future = backend.futureForPath("_", method: .GET)
        let expectation = self.expectationWithDescription("Expected .Failure with .BadURL error")
        future.start { result in
            guard case
            .Failure(let error) = result,
            .BadURL = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testHTTPResponseParserCall() {
        let session = FakeURLSession()
        let exampleData = NSData()
        let exampleURLResponse = NSURLResponse()
        let exampleError = NSError(domain: "Test", code: 2, userInfo: nil)
        session.data = exampleData
        session.urlResponse = exampleURLResponse
        session.error = exampleError
        let parser = FakeHTTPResponseParser()
        let backend = ServerBackend(session: session, responseParser: parser)
        let future = backend.futureForPath("_", method: .GET)
        let expectation = self.expectationWithDescription("Expected .Failure with .BadURL error")
        future.start { _ in expectation.fulfill() }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
            guard let response = parser.response else { XCTFail(); return }
            XCTAssertEqual(response.data, exampleData)
            XCTAssertEqual(response.urlResponse, exampleURLResponse)
            XCTAssertEqual(response.error, exampleError)
        }
    }
    
    func testHTTPResponseParserSuccessCallback() {
        let session = FakeURLSession()
        let exampleData: NSData? = NSData()
        let examplePageInfo: PageInfo? = PageInfo(number: 1, size: 2, total: 10)
        let result = HTTPResponseParserResult.Success((data: exampleData, pageInfo: examplePageInfo))
        let parser = FakeHTTPResponseParser(result: result)
   
        let backend = ServerBackend(session: session, responseParser: parser)
        let future = backend.futureForPath("_", method: .GET)
        let expectation = self.expectationWithDescription("Expected .Failure with .BadURL error")
        future.start { result in
            guard case .Success(let data, let pageInfo) = result
                else { return }
            XCTAssertEqual(data, exampleData)
            XCTAssertEqual(pageInfo, examplePageInfo)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testHTTPResponseParserFailureCallback() {
        let session = FakeURLSession()
        let exampleError = ServerBackendError.ServerError(statusCode: 500)
        let result = HTTPResponseParserResult.Failure(exampleError)
        let parser = FakeHTTPResponseParser(result: result)
        
        let backend = ServerBackend(session: session, responseParser: parser)
        let future = backend.futureForPath("_", method: .GET)
        let expectation = self.expectationWithDescription("Expected .Failure with .ServerError")
        future.start { result in
            guard case
                .Failure(let error) = result,
                .ServerError(let code) = error
                else { return }
            XCTAssertEqual(code, 500)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}

extension PageInfo: Equatable {}
public func ==(lhs: PageInfo, rhs: PageInfo) -> Bool {
    return lhs.number == rhs.number
    && lhs.size == rhs.size
    && lhs.more == rhs.more
}
