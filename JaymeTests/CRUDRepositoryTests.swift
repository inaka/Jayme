// Jayme
// CRUDRepositoryTests.swift
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

// swiftlint:disable file_length

import XCTest
@testable import Jayme

class CRUDRepositoryTests: XCTestCase {
    
    var backend: TestingBackend!
    var repository: TestDocumentRepository!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        
        let backend = TestingBackend()
        self.backend = backend
        self.repository = TestDocumentRepository(backend: backend)
    }
    
}

// MARK: - Calls To Backend Tests

extension CRUDRepositoryTests {
    
    func testFindAllCall() {
        self.repository.findAll()
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    func testFindByIDCall() {
        self.repository.findByID("123")
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    func testCreateCall() {
        let document = TestDocument(id: "123", name: "a")
        self.repository.create(document)
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .POST)
        guard let
            id = self.backend.parameters?["id"] as? String,
            name = self.backend.parameters?["name"] as? String else {
                XCTFail("Wrong parameters"); return
        }
        XCTAssertEqual(id, "123")
        XCTAssertEqual(name, "a")
    }
    
    func testUpdateCall() {
        let document = TestDocument(id: "123", name: "b")
        self.repository.update(document)
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .PUT)
        guard let
            id = self.backend.parameters?["id"] as? String,
            name = self.backend.parameters?["name"] as? String else {
                XCTFail("Wrong parameters"); return
        }
        XCTAssertEqual(id, "123")
        XCTAssertEqual(name, "b")
    }
    
    func testDeleteCall() {
        let document = TestDocument(id: "123", name: "a")
        self.repository.delete(document)
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .DELETE)
    }
    
}

// MARK: - Response Callbacks Tests

extension CRUDRepositoryTests {
    
    func testFindAllSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a"],
                        ["id": "2", "name": "b"]]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected 2 documents to be parsed")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard case .Success(let documents) = result
                else { XCTFail(); return }
            XCTAssertEqual(documents.count, 2)
            XCTAssertEqual(documents[0].id, "1")
            XCTAssertEqual(documents[0].name, "a")
            XCTAssertEqual(documents[1].id, "2")
            XCTAssertEqual(documents[1].name, "b")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindAllFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected JaymeError.NotFound")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard case .Failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindAllFailureBadResponseCallback() {
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = NSData()
            completion(.Success((corruptedData, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a .BadResponse error")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard case
                .Failure(let error) = result,
                .BadResponse = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIDSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to find a document")
        
        let future = self.repository.findByID("1")
        future.start() { result in
            guard case .Success(let document) = result
                else { XCTFail(); return }
            XCTAssertEqual(document.id, "1")
            XCTAssertEqual(document.name, "a")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIDFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a .NotFound error")
        
        let future = self.repository.findByID("_")
        future.start() { result in
            guard case
                .Failure(let error) = result,
                .NotFound = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIDFailureBadResponseCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = NSData()
            completion(.Success((corruptedData, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a .BadResponse error")
        
        let future = self.repository.findByID("_")
        future.start() { result in
            guard case
                .Failure(let error) = result,
                .BadResponse = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIDFailureParsingErrorCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let wrongDictionary = ["id": "_"] // lacks 'name' field
            let data = try! NSJSONSerialization.dataWithJSONObject(wrongDictionary, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a .BadResponse error")
        
        let future = self.repository.findByID("_")
        future.start() { result in
            guard case
                .Failure(let error) = result,
                .ParsingError = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCreateSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.create(document)
        future.start() { result in
            guard case .Success(let document) = result
                else { XCTFail(); return }
            XCTAssertEqual(document.id, "1")
            XCTAssertEqual(document.name, "a")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testCreateFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected to get an error")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.create(document)
        future.start() { result in
            guard case .Failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    
    func testUpdateSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document)
        future.start() { result in
            guard case .Success(let document) = result
                else { XCTFail(); return }
            XCTAssertEqual(document.id, "1")
            XCTAssertEqual(document.name, "a")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testUpdateFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected to get an error")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document)
        future.start() { result in
            guard case .Failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testDeleteSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            completion(.Success((nil, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.delete(document)
        future.start() { result in
            guard case .Success = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testDeleteFailureCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.NotFound
            completion(.Failure(error))
        }
        
        let expectation = self.expectationWithDescription("Expected to get an error")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.delete(document)
        future.start() { result in
            guard case .Failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
}
