// JaymeExample
// UserRepositoryTests.swift
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

class UserRepositoryTests: XCTestCase {
    
    var backend: TestingBackend!
    var repository: UserRepository!
    
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
        
        let backend = TestingBackend() 
        self.backend = backend
        self.repository = UserRepository(backend: backend)
    }
    
}

extension UserRepositoryTests {
    
    // Test path and method
    
    func testFindActiveUsersCall() {
        self.repository.findActiveUsers()
        XCTAssertEqual(self.backend.path, "users/active")
        XCTAssertEqual(self.backend.method, .GET)
    }
    
    // Test success and parsing
    
    func testFindActiveUsersSuccessCallback() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let json = [["id": "1", "name": "a", "email": "a@a.com"],
                        ["id": "2", "name": "b", "email": "b@b.com"]]
            let data = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected 2 users to be parsed")
        
        let future = self.repository.findActiveUsers()
        future.start() { result in
            guard case .Success(let documents) = result
                else { XCTFail(); return }
            XCTAssertEqual(documents.count, 2)
            XCTAssertEqual(documents[0].id, "1")
            XCTAssertEqual(documents[0].name, "a")
            XCTAssertEqual(documents[0].email, "a@a.com")

            XCTAssertEqual(documents[1].id, "2")
            XCTAssertEqual(documents[1].name, "b")
            XCTAssertEqual(documents[1].email, "b@b.com")

            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
    
    func testFindActiveUsersBadParsingShouldSuccessWithNoResults() {
        
        // Simulated completion
        self.backend.completion = { completion in
            let wrongResponse = [["id": "1", "name": "_"]] // lacks 'email' field
            let data = try! NSJSONSerialization.dataWithJSONObject(wrongResponse, options: .PrettyPrinted)
            completion(.Success((data, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get JaymeError.ParsingError")
        
        let future = self.repository.findActiveUsers()
        future.start() { result in
            guard case .Success(let users) = result
                else { XCTFail(); return }
            XCTAssertEqual(users.count, 0)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3) { error in
            if let _ = error { XCTFail() }
        }
    }
   
    // Test possible failures
    
    func testFindActiveUsersFailureBadResponseCallback() {
        // Simulated completion
        self.backend.completion = { completion in
            let corruptedData = NSData()
            completion(.Success((corruptedData, nil)))
        }
        
        let expectation = self.expectationWithDescription("Expected to get JaymeError.BadResponse")
        
        let future = self.repository.findActiveUsers()
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
    
}
