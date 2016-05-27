// Jayme
// Backend.swift
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

public typealias Path = String

/// Abstraction for performing asynchronous operations and returning a `Future` given a path, an HTTP method and, optionally, a parameters dictionary.
public protocol Backend {
    
    /// The associated type for returning within the `Future` object in `futureForPath`
    /// Classes conforming to `Backend` must tie this associated type to a concrete type
    associatedtype BackendReturnType
    
    /// The associated type for handling errors within the `Future` object in `futureForPath`
    /// Classes conforming to `Backend` must tie this associated type to a concrete type
    associatedtype BackendErrorType: ErrorType
    
    /// Returns a `Future` for a given path with a specific HTTPMethod, optionally passing a parameters dictionary.
    func futureForPath(path: String, method: HTTPMethodName, parameters: [String: AnyObject]?) -> Future<BackendReturnType, BackendErrorType>
    
}
