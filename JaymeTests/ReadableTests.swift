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

// MARK: - Read All

extension ReadableTests {
    
    // MARK: - Call To Backend
    
    func testReadAllCall() {
        let _ = self.repository.readAll()
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // MARK: - Success Response
    
    func testReadAllSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a"],
                        ["id": "2", "name": "b"]]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected 2 documents to be parsed")
        
        let future = self.repository.readAll()
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
    
    func testReadAllFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected JaymeError.NotFound")
        
        let future = self.repository.readAll()
        future.start() { result in
            guard case .failure = result
                else { XCTFail(); return }
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testReadAllFailureBadResponseCallback() {
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = Data()
            completion(.success((corruptedData, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get a JaymeError.BadResponse")
        
        let future = self.repository.readAll()
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

// MARK: - Read By ID

extension ReadableTests {
    
    // MARK: - Call To Backend
    
    func testReadByIdCall() {
        let _ = self.repository.read(byId: "123")
        XCTAssertEqual(self.backend.path, "documents/123")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // MARK: - Success Response
    
    func testReadByIdSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to find a document")
        
        let future = self.repository.read(byId: "1")
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
    
    func testReadByIdFailureNotFoundCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let error = JaymeError.notFound
            completion(.failure(error))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.NotFound")
        
        let future = self.repository.read(byId: "_")
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
    
    func testReadByIdFailureBadResponseCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = Data()
            completion(.success((corruptedData, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.BadResponse")
        
        let future = self.repository.read(byId: "_")
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
    
    func testReadByIdFailureParsingErrorCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let wrongDictionary = ["id": "_"] // lacks 'name' field
            let data = try! JSONSerialization.data(withJSONObject: wrongDictionary, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.ParsingError")
        
        let future = self.repository.read(byId: "_")
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

// MARK: - Read (Single Entity)

extension ReadableTests {
    
    // MARK: - Call To Backend
    
    func testReadSingleEntityCall() {
        let _ = self.repository.read()
        XCTAssertEqual(self.backend.path, "documents")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // MARK: - Success Response
    
    func testReadSingleEntitySuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = ["id": "1", "name": "a"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to find a document")
        
        let future = self.repository.read()
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
    
    func testReadSingleEntityFailureBadResponseCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = Data()
            completion(.success((corruptedData, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.BadResponse")
        
        let future = self.repository.read()
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
    
    func testReadSingleEntityFailureParsingErrorCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let wrongDictionary = ["id": "_"] // lacks 'name' field
            let data = try! JSONSerialization.data(withJSONObject: wrongDictionary, options: .prettyPrinted)
            completion(.success((data, nil)))
        }
        
        let expectation = self.expectation(description: "Expected to get JaymeError.ParsingError")
        
        let future = self.repository.read()
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
