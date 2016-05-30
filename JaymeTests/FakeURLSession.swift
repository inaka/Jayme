// Jayme
// FakeURLSession.swift
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

import Foundation

typealias DataTaskCompletion = ((NSData?, NSURLResponse?, NSError?) -> ())

class FakeURLSession: NSURLSession {
    
    var data: NSData?
    var urlResponse: NSURLResponse?
    var error: NSError?
    var request: NSURLRequest?
    
    init(completion: DataTaskCompletion? = nil) {
        self.completion = completion
    }
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: DataTaskCompletion) -> NSURLSessionDataTask {
        self.request = request
        if self.completion == nil {
            self.completion = completionHandler
        }
        return FakeURLSessionDataTask(session: self)
    }
    
    // MARK: - Private
    
    private var completion: DataTaskCompletion?
    private func executeCompletion() {
        self.completion?(self.data, self.urlResponse, self.error)
    }
    
}

class FakeURLSessionDataTask: NSURLSessionDataTask {
    
    private let session: FakeURLSession
    
    init(session: FakeURLSession) {
        self.session = session
    }
    
    override func resume() {
        self.session.executeCompletion()
    }
    
}
