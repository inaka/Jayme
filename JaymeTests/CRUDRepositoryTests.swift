// Jayme
// CRUDRepositoryTests.swift
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
        XCTAssertEqual(self.backend.path, "documents/123")
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
        guard let
            id = self.backend.parameters?["id"] as? String,
            name = self.backend.parameters?["name"] as? String else {
                XCTFail("Wrong parameters"); return
        }
        XCTAssertEqual(id, "123")
        XCTAssertEqual(name, "a")
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
            completion(.Success((nil, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.create(document)
        future.start() { result in
            guard case .Success = result
                else { XCTFail(); return }
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
            completion(.Success((nil, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get a success")
        
        let document = TestDocument(id: "_", name: "_")
        let future = self.repository.update(document)
        future.start() { result in
            guard case .Success = result
                else { XCTFail(); return }
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
