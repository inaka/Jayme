// Jayme
// ReadableTests.swift
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

class ReadableTests: XCTestCase {
    
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

// MARK: - Find All

extension ReadableTests {
    
    // MARK: - Call To Backend
    
    func testFindAllCall() {
        let _ = self.repository.findAll()
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // MARK: - Success Response
    
    func testFindAllSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a"],
                        ["id": "2", "name": "b"]]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected 2 documents to be parsed")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard case .success(let documents) = result
                else { XCTFail(); return }
            XCTAssertEqual(documents.count, 2)
            XCTAssertEqual(documents[0].id, "1")
            XCTAssertEqual(documents[0].name, "a")
            XCTAssertEqual(documents[1].id, "2")
            XCTAssertEqual(documents[1].name, "b")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    // MARK: - Failure Response
    
    func testFindAllFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected JaymeError.NotFound")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard case .failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindAllFailureBadResponseCallback() {
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = Data()
            completion(.success((corruptedData, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get a JaymeError.BadResponse")
        
        let future = self.repository.findAll()
        future.start() { result in
            guard
                case .failure(let error) = result,
                case .badResponse = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
}

// MARK: - Find By ID

extension ReadableTests {
    
    // MARK: - Call To Backend
    
    func testFindByIdCall() {
        let _ = self.repository.find(byId: "123")
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // MARK: - Success Response
    
    func testFindByIdSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to find a document")
        
        let future = self.repository.find(byId: "1")
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
    
    func testFindByIdFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.NotFound")
        
        let future = self.repository.find(byId: "_")
        future.start() { result in
            guard
                case .failure(let error) = result,
                case .notFound = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIdFailureBadResponseCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = Data()
            completion(.success((corruptedData, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.BadResponse")
        
        let future = self.repository.find(byId: "_")
        future.start() { result in
            guard
                case .failure(let error) = result,
                case .badResponse = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindByIdFailureParsingErrorCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let wrongDictionary = ["id": "_"] // lacks 'name' field
            let data = try! JSONSerialization.data(withJSONObject: wrongDictionary, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.ParsingError")
        
        let future = self.repository.find(byId: "_")
        future.start() { result in
            guard
                case .failure(let error) = result,
                case .parsingError = error
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
}

