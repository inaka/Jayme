// Jayme
// HTTPResponseParser.swift
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
