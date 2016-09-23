// Jayme
// PagedRepositoryTests.swift
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

class PagedRepositoryTests: XCTestCase {

    var backend: TestingBackend!
    var repository: TestDocumentPagedRepository!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        
        let backend = TestingBackend()
        self.backend = backend
        self.repository = TestDocumentPagedRepository(backend: backend, pageSize: 2)
    }
}

// MARK: - Calls To Backend Tests

extension PagedRepositoryTests {
    
    func testFindAllCall() {
        let _ = self.repository.findByPage(pageNumber: 1)
        XCTAssertEqual(self.backend.path, "documents?page=1&per_page=2")
    }
    
}

// MARK: - Response Parsing Tests

extension PagedRepositoryTests {

    // Check the PageInfo object that is returned
    func testFindAllSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a"],
                        ["id": "2", "name": "b"]]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let pageInfo = PageInfo(number: 1, size: 2, total: 10)
            completion(.success((data, pageInfo)))
        }
        
        let expectation = self.expectation(description: "Expected 2 documents to be parsed with proper PageInfo")
        
        let future = self.repository.findByPage(pageNumber: 1)
        future.start() { result in
            guard case .success(let documents, let pageInfo) = result else {
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
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error {
                XCTFail()
                return
            }
        }
    }
    
    func testFindAllFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected JaymeError.NotFound")
        
        let future = self.repository.findByPage(pageNumber: 1)
        future.start() { result in
            guard case .failure = result else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error {
                XCTFail()
                return
            }
        }
    }
}
