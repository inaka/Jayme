// Jayme
// ServerPagedRepositoryTests.swift
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

class ServerPagedRepositoryTests: XCTestCase {

    var backend: FakeServerBackend!
    var repository: TestDocumentPagedRepository!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        
        let backend = FakeServerBackend()
        self.backend = backend
        self.repository = TestDocumentPagedRepository(backend: backend, pageSize: 2)
    }
}

// MARK: - Calls To Backend Tests

extension ServerPagedRepositoryTests {
    
    func testFindAllCall() {
        self.repository.findAll(pageNumber: 1)
        XCTAssertEqual(self.backend.path, "documents?page=1&per_page=2")
    }
    
}

// MARK: - Response Parsing Tests

extension ServerPagedRepositoryTests {

    // Check the PageInfo object that is returned
    func testFindAllSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a"],
                        ["id": "2", "name": "b"]]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let pageInfo = PageInfo(number: 1, size: 2, total: 10)
            completion(.Success((data, pageInfo)))
        }
        
        let expectation = self.expectationWithDescription("Expected 2 documents to be parsed with proper PageInfo")
        
        let future = self.repository.findAll(pageNumber: 1)
        future.start() { result in
            guard case .Success(let documents, let pageInfo) = result else {
                XCTFail()
                return
            }
            XCTAssertEqual(documents.count, 2)
            XCTAssertEqual(documents[0].id, "1")
            XCTAssertEqual(documents[0].name, "a")
            XCTAssertEqual(documents[1].id, "2")
            XCTAssertEqual(documents[1].name, "b")
            XCTAssertEqual(pageInfo.number, 1)
            XCTAssertEqual(pageInfo.size, 2)
            XCTAssertEqual(pageInfo.total, 10)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error {
                XCTFail()
                return
            }
        }
    }
    
    func testFindAllFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = ServerBackendError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected ServerBackendError.NotFound")
        
        let future = self.repository.findAll(pageNumber: 1)
        future.start() { result in
            guard case .Failure = result else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error {
                XCTFail()
                return
            }
        }
    }
}
