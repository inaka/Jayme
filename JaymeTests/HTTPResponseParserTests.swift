// Jayme
// HTTPResponseParserTests.swift
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

class HTTPResponseParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
}

// MARK: - Failure Tests

extension HTTPResponseParserTests {
    
    func testBadResponse() {
        let response: FullHTTPResponse = (data: nil, urlResponse: nil, error: nil)
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .BadResponse = error
            else { XCTFail(); return }
    }
    
    func testNSError() {
        let exampleError = NSError(domain: "Test", code: 1, userInfo: nil)
        let response: FullHTTPResponse = (data: nil, urlResponse: nil, error: exampleError)
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .Other(let nsError) = error
            else { XCTFail(); return }
        XCTAssertEqual(nsError, exampleError)
    }
    
}

// MARK: - Successful Response - Status Code Parsing Tests

extension HTTPResponseParserTests {
    
    func test200Success() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case .Success(let data, _) = result
            else { XCTFail(); return }
        XCTAssertEqual(data, exampleData)
    }
    
    func test204Success() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 204, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case .Success(let data, _) = result
            else { XCTFail(); return }
        XCTAssertEqual(data, exampleData)
    }
    
    func test403Forbidden() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 403, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .Undefined(let statusCode) = error
            else { XCTFail(); return }
        XCTAssertEqual(statusCode, 403)
    }
    
    func test404NotFound() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 404, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .NotFound = error
            else { XCTFail(); return }
    }
    
    func test410Gone() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 410, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .NotFound = error
            else { XCTFail(); return }
    }
    
    func test500ServerInternalError() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 500, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .ServerError(let statusCode) = error
            else { XCTFail(); return }
        XCTAssertEqual(statusCode, 500)
    }
    
    func test503ServiceUnavailable() {
        let url = NSURL(string: "_")!
        let exampleData = NSData()
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 503, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: exampleData, urlResponse: urlResponse, error: nil)
        
        let result = HTTPResponseParser().parseResponse(response)
        guard case
            .Failure(let error) = result,
            .ServerError(let statusCode) = error
            else { XCTFail(); return }
        XCTAssertEqual(statusCode, 503)
    }
    
}

// MARK: - Successful Response - Pagination Related Tests

extension HTTPResponseParserTests {

    func testWithoutPageInfo() {
        let url = NSURL(string: "_")!
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
        let response: FullHTTPResponse = (data: nil, urlResponse: urlResponse, error: nil)
        let result = HTTPResponseParser().parseResponse(response)
        guard case .Success(_, let pageInfo) = result
            else { XCTFail(); return }
        XCTAssertNil(pageInfo)
    }
    
    func testWithPageInfo() {
        // Using standard pagination headers described here:
        // https://github.com/davidcelis/api-pagination
        
        let url = NSURL(string: "_")!
        let headerFields = ["X-Total": "100",
                            "X-Per-Page": "20",
                            "X-Page": "5"]
        let urlResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: headerFields)
        let response: FullHTTPResponse = (data: nil, urlResponse: urlResponse, error: nil)
        let result = HTTPResponseParser().parseResponse(response)
        guard case .Success(_, let maybePageInfo) = result
            else { XCTFail(); return }
        guard let pageInfo = maybePageInfo
            else { XCTFail(); return }
        XCTAssertEqual(pageInfo.number, 5)
        XCTAssertEqual(pageInfo.size, 20)
        XCTAssertEqual(pageInfo.total, 100)
    }
    
}
