// Jayme
// HTTPResponseParser.swift
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

typealias FullHTTPResponse = (data: NSData?, urlResponse: NSURLResponse?, error: NSError?)
typealias HTTPResponseParserResult = Result<(data: NSData?, pageInfo: PageInfo?), JaymeError>

public class HTTPResponseParser {
    
    func parseResponse(response: FullHTTPResponse) -> HTTPResponseParserResult {
        if let error = response.error {
            return .Failure(.Other(error))
        }
        guard let urlResponse = response.urlResponse as? NSHTTPURLResponse else {
            return .Failure(.BadResponse)
        }
        if let error = self.errorForStatusCode(urlResponse.statusCode) {
            return .Failure(error)
        }
        let pageInfo = self.pageInfoFromHeaders(urlResponse.allHeaderFields)
        return .Success(data: response.data, pageInfo: pageInfo)
    }
    
    // MARK: - Private
    
    private func errorForStatusCode(code: Int) -> JaymeError? {
        switch code {
        case 200...299:
            return nil
        case 404, 410:
            return .NotFound
        case 500...599:
            return .ServerError(statusCode: code)
        default:
            return .Undefined(statusCode: code)
        }
    }
    
    private func pageInfoFromHeaders(headers: [NSObject: AnyObject]) -> PageInfo? {
        guard let
            totalString = headers["X-Total"] as? String,
            perPageString = headers["X-Per-Page"] as? String,
            pageString = headers["X-Page"] as? String,
            total = Int(totalString),
            perPage = Int(perPageString),
            page = Int(pageString)
            else { return nil }
        return PageInfo(number: page, size: perPage, total: total)
    }
    
}
