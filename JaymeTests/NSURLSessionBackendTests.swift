// Jayme
// NSURLSessionBackendTests.swift
//
// Copyright (c) 2016 Inaka - http://inaka.net/
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements. See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership. The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import XCTest
@testable import Jayme

class NSURLSessionBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
}

// MARK: - Tests

extension NSURLSessionBackendTests {
    
    func testBadURL() {
        let configuration = NSURLSessionBackendConfiguration(basePath: "http://próblematiç_url", httpHeaders: [])
        let backend = NSURLSessionBackend(configuration: configuration)
        let future = backend.futureForPath("_", method: .GET)
        let expectation = self.expectationWithDescription("Expected .Failure with .BadRequest error")
        future.start { result in
            guard case
            .Failure(let error) = result,
            .BadRequest = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }

    func testBadParameters() {
        let backend = NSURLSessionBackend()
        let problematicString = String(bytes: [0xD8, 0x00] as [UInt8], encoding: NSUTF16BigEndianStringEncoding)!
        let problematicParams = ["foo": problematicString]
        let future = backend.futureForPath("_", method: .GET, parameters: problematicParams)
        let expectation = self.expectationWithDescription("Expected .Failure with .BadRequest error")
        future.start { result in
            guard case
                .Failure(let error) = result,
                .BadRequest = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testNSURLRequestComposition() {
        let session = FakeURLSession()
        let parser = FakeHTTPResponseParser()
        let headers = [HTTPHeader(field: "Content-Type", value: "application/json")]
        let configuration = NSURLSessionBackendConfiguration(basePath: "http://localhost:8080", httpHeaders: headers)
        let backend = NSURLSessionBackend(configuration: configuration, session: session, responseParser: parser)
        let future = backend.futureForPath("/users/1", method: .PUT, parameters: ["id": "1", "name": "John"])
        let expectation = self.expectationWithDescription("Expected NSURLRequest with proper path, method, parameters and headers.")
        future.start { _ in expectation.fulfill() }
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
            guard let request = session.request else { XCTFail(); return }
            XCTAssertNotNil(request.URL)
            XCTAssertEqual(request.URL!.absoluteString, "http://localhost:8080/users/1")
            XCTAssertEqual(request.HTTPMethod, "PUT")
            XCTAssertEqual(request.valueForHTTPHeaderField("Content-Type"), "application/json")
            guard let body = request.HTTPBody else { XCTFail(); return }
            guard let json = try? NSJSONSerialization.JSONObjectWithData(body, options: .AllowFragments) else { XCTFail(); return }
            guard let params = json as? [String: String] else { XCTFail(); return }
            XCTAssertEqual(params["id"], "1")
            XCTAssertEqual(params["name"], "John")
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
        let backend = NSURLSessionBackend(session: session, responseParser: parser)
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
   
        let backend = NSURLSessionBackend(session: session, responseParser: parser)
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
        let exampleError = JaymeError.ServerError(statusCode: 500)
        let result = HTTPResponseParserResult.Failure(exampleError)
        let parser = FakeHTTPResponseParser(result: result)
        
        let backend = NSURLSessionBackend(session: session, responseParser: parser)
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
public func == (lhs: PageInfo, rhs: PageInfo) -> Bool {
    return lhs.number == rhs.number
    && lhs.size == rhs.size
    && lhs.total == rhs.total
}
