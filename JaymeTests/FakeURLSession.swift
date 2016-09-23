// Jayme
// FakeURLSession.swift
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

import Foundation

typealias DataTaskCompletion = ((Data?, URLResponse?, Error?) -> ())

class FakeURLSession: URLSession {
    
    var data: Data?
    var urlResponse: URLResponse?
    var error: NSError?
    var request: URLRequest?
    
    init(completion: DataTaskCompletion? = nil) {
        self.completion = completion
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTask {
        self.request = request
        if self.completion == nil {
            self.completion = completionHandler
        }
        return FakeURLSessionDataTask(session: self)
    }
    
    // MARK: - Private
    
    fileprivate var completion: DataTaskCompletion?
    fileprivate func executeCompletion() {
        self.completion?(self.data, self.urlResponse, self.error)
    }
    
}

class FakeURLSessionDataTask: URLSessionDataTask {
    
    fileprivate let session: FakeURLSession
    
    init(session: FakeURLSession) {
        self.session = session
    }
    
    override func resume() {
        self.session.executeCompletion()
    }
    
}
