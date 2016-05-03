// Jayme
// ServerBackendError.swift
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

/// Discrete enumeration representing the possible errors that can be produced within the ServerBackend and ServerRepository layers.
public enum ServerBackendError: ErrorType {
    
    /* URL string is bad formed such that NSURL can't be built
     */
    case BadURL
    
    /* No error was produced, but either no valid response was found or the returned `NSData` object is corrupted or unexpected
     */
    case BadResponse
    
    /* Returned `NSData` object could not be parsed as expected
     */
    case ParsingError
    
    /* Server returned 404 or 410. Useful as a special case in `.findByID()` requests
     */
    case NotFound
    
    /* Server returned any 5xx status code
     Contains the 5xx status code
     */
    case ServerError(statusCode: Int)
    
    /* Server returned any other status code that is not contemplated as a special case
     */
    case Undefined(statusCode: Int)
    
    /* An error occurred while sending the request (e.g. a timeout or no internet connection)
     Contains the `NSError` with the information about it
     */
    case Other(NSError)
    
}
