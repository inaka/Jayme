// Jayme
// NSURLSessionBackendConfiguration.swift
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

/// Structure used for holding relevant information that NSURLSessionBackend needs in order to work.
public struct NSURLSessionBackendConfiguration {
    
    public let basePath: Path
    public let httpHeaders: [HTTPHeader]
    
    public static var defaultConfiguration = NSURLSessionBackendConfiguration(basePath: "http://localhost:8080",
                                                                 httpHeaders: NSURLSessionBackendConfiguration.defaultHTTPHeaders)
    
    // MARK: - Private
    
    private static var defaultHTTPHeaders = [HTTPHeader(field: "Accept", value: "application/json"),
                                             HTTPHeader(field: "Content-Type", value: "application/json")]
    
    init(basePath: Path, httpHeaders: [HTTPHeader]){
        self.basePath = basePath
        self.httpHeaders = httpHeaders
    }
}
