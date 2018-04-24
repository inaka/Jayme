// Jayme
// URLSessionBackendTests.swift
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

class URLSessionBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
}

// MARK: - Tests

extension URLSessionBackendTests {
    
    func testBadURL() {
        let configuration = URLSessionBackendConfiguration(basePath: "http://próblematiç_url", httpHeaders: [])
        let backend = URLSessionBackend(configuration: configuration)
        let future = backend.future(path: "_", method: .GET)
        let expectation = self.expectation(description: "Expected .Failure with .BadRequest error")
        future.start { result in
            guard
                case .failure(let error) = result,
                case .badRequest = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }

    func testBadParameters() {
        let backend = URLSessionBackend()
        let problematicString = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)!
        let problematicParams: [[AnyHashable: Any]] = [["foo": problematicString]]
        let future = backend.future(path: "_", method: .GET, parameters: problematicParams)
        let expectation = self.expectation(description: "Expected .Failure with .BadRequest error")
        future.start { result in
            guard
                case .failure(let error) = result,
                case .badRequest = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testNSURLRequestComposition() {
        let session = FakeURLSession()
        let parser = FakeHTTPResponseParser()
        let headers = [HTTPHeader(field: "Content-Type", value: "application/json")]
        let configuration = URLSessionBackendConfiguration(basePath: "http://localhost:8080", httpHeaders: headers)
        let backend = URLSessionBackend(configuration: configuration, session: session, responseParser: parser)
        let future = backend.future(path: "/users/1", method: .PUT, parameters: ["id": "1", "name": "John"])
        let expectation = self.expectation(description: "Expected NSURLRequest with proper path, method, parameters and headers.")
        future.start { _ in expectation.fulfill() }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
            guard let request = session.request else { XCTFail(); return }
            XCTAssertNotNil(request.url)
            XCTAssertEqual(request.url!.absoluteString, "http://localhost:8080/users/1")
            XCTAssertEqual(request.httpMethod, "PUT")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            guard let body = request.httpBody else { XCTFail(); return }
            guard let json = try? JSONSerialization.jsonObject(with: body, options: .allowFragments) else { XCTFail(); return }
            guard let params = json as? [String: String] else { XCTFail(); return }
            XCTAssertEqual(params["id"], "1")
            XCTAssertEqual(params["name"], "John")
        }
    }
    
    func testHTTPResponseParserCall() {
        let session = FakeURLSession()
        let exampleData = Data()
        let exampleURLResponse = URLResponse()
        let exampleError = NSError(domain: "Test", code: 2, userInfo: nil)
        session.data = exampleData
        session.urlResponse = exampleURLResponse
        session.error = exampleError
        let parser = FakeHTTPResponseParser()
        let backend = URLSessionBackend(session: session, responseParser: parser)
        let future = backend.future(path: "_", method: .GET)
        let expectation = self.expectation(description: "Expected .Failure with .BadURL error")
        future.start { _ in expectation.fulfill() }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
            guard
                let response = parser.response,
                let error = response.error as NSError?
                else { XCTFail(); return }
            XCTAssertEqual(response.data, exampleData)
            XCTAssertEqual(response.urlResponse, exampleURLResponse)
            XCTAssertEqual(error, exampleError)
        }
    }
    
    func testHTTPResponseParserSuccessCallback() {
        let session = FakeURLSession()
        let exampleData: Data? = Data()
        let examplePageInfo: PageInfo? = PageInfo(number: 1, size: 2, total: 10)
        let result = HTTPResponseParserResult.success((data: exampleData, pageInfo: examplePageInfo))
        let parser = FakeHTTPResponseParser(result: result)
   
        let backend = URLSessionBackend(session: session, responseParser: parser)
        let future = backend.future(path: "_", method: .GET)
        let expectation = self.expectation(description: "Expected .Failure with .BadURL error")
        future.start { result in
            guard case .success(let data, let pageInfo) = result
                else { return }
            XCTAssertEqual(data, exampleData)
            XCTAssertEqual(pageInfo, examplePageInfo)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testHTTPResponseParserFailureCallback() {
        let session = FakeURLSession()
        let exampleError = JaymeError.serverError(statusCode: 500)
        let result = HTTPResponseParserResult.failure(exampleError)
        let parser = FakeHTTPResponseParser(result: result)
        
        let backend = URLSessionBackend(session: session, responseParser: parser)
        let future = backend.future(path: "_", method: .GET)
        let expectation = self.expectation(description: "Expected .Failure with .ServerError")
        future.start { result in
            guard
                case .failure(let error) = result,
                case .serverError(let code) = error
                else { return }
            XCTAssertEqual(code, 500)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 3) { error in
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
