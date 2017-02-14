// Jayme
// UpdatableTests.swift
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

class UpdatableTests: XCTestCase {
    
    var backend: TestingBackend!
    var repository: TestDocumentRepository!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        
        let backend = TestingBackend()
        self.backend = backend
        self.repository = TestDocumentRepository(backend: self.backend)
    }
    
}

// MARK: - Update Single Entity

extension UpdatableTests {
    
    // MARK: - Call To backend
    
    func testUpdateSingleEntityCall() {
        let document = TestDocument(id: "123", name: "b")
        let _ = self.repository.update(document)
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .PUT)
        guard let
            id = self.backend.parameters?["id"] as? String,
            let name = self.backend.parameters?["name"] as? String else {
                XCTFail("Wrong parameters"); return
        }
        XCTAssertEqual(id, "123")
        XCTAssertEqual(name, "b")
    }
    
    // MARK: - Success Response
    
    func testUpdateSingleEntitySuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document)
        future.start() { result in
            guard case .success(let document) = result
                else { XCTFail(); return }
            XCTAssertEqual(document.id, "1")
            XCTAssertEqual(document.name, "a")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
        
    }
    
    // MARK: - Failure Response
    
    func testUpdateSingleEntityFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected to get an error")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document)
        future.start() { result in
            guard case .failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}

// MARK: - Update By Id

extension UpdatableTests {
    
    // MARK: - Call To backend
    
    func testUpdateByIdCall() {
        let document = TestDocument(id: "123", name: "b")
        let _ = self.repository.update(document, id: "123")
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .PUT)
        guard let
            id = self.backend.parameters?["id"] as? String,
            let name = self.backend.parameters?["name"] as? String else {
                XCTFail("Wrong parameters"); return
        }
        XCTAssertEqual(id, "123")
        XCTAssertEqual(name, "b")
    }
    
    // MARK: - Success Response
    
    func testUpdateByIdSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document, id: "_")
        future.start() { result in
            guard case .success(let document) = result
                else { XCTFail(); return }
            XCTAssertEqual(document.id, "1")
            XCTAssertEqual(document.name, "a")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
        
    }
    
    // MARK: - Failure Response
    
    func testUpdateByIdFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected to get an error")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document, id: "_")
        future.start() { result in
            guard case .failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}
