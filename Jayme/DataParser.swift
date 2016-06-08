// Jayme
// DataParser.swift
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

/// Provides functions to be used within a repository for converting Dictionaries into Entities an chaining their results with `Future` convenient functions (e.g. `map` and `andThen`
public class DataParser {
    
    /// Public default initializer
    public init() { }
    
    /// Returns a `Future` containing a dictionary initialized with the optional data passed by parameter, or `JaymeError.BadResponse` if the dictionary can't be initialized from that data.
    public func dictionaryFromData(maybeData: NSData?) -> Future<[String: AnyObject], JaymeError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                dictionary = result as? [String: AnyObject]
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(dictionary))
        }
    }
    
     /// Returns a `Future` containing an array of dictionaries initialized with the optional data passed by parameter, or `JaymeError.BadResponse` if the array can't be initialized from that data.
    public func dictionariesFromData(maybeData: NSData?) -> Future<[[String: AnyObject]], JaymeError> {
        return Future() { completion in
            guard let
                data = maybeData,
                result = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
                array = result as? [[String: AnyObject]]
                else {
                    completion(.Failure(.BadResponse))
                    return
            }
            completion(.Success(array))
        }
    }
    
}
