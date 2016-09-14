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

typealias FullHTTPResponse = (data: Data?, urlResponse: URLResponse?, error: Error?)
typealias HTTPResponseParserResult = Result<(data: Data?, pageInfo: PageInfo?), JaymeError>

open class HTTPResponseParser {
    
    func parseResponse(_ response: FullHTTPResponse) -> HTTPResponseParserResult {
        if let error = response.error {
            return .failure(.other(error))
        }
        guard let urlResponse = response.urlResponse as? HTTPURLResponse else {
            return .failure(.badResponse)
        }
        if let error = self.errorForStatusCode(urlResponse.statusCode) {
            return .failure(error)
        }
        let pageInfo = self.pageInfoFromHeaders(urlResponse.allHeaderFields)
        return .success(data: response.data, pageInfo: pageInfo)
    }
    
    // MARK: - Private
    
    fileprivate func errorForStatusCode(_ code: Int) -> JaymeError? {
        switch code {
        case 200...299:
            return nil
        case 404, 410:
            return .notFound
        case 500...599:
            return .serverError(statusCode: code)
        default:
            return .undefined(statusCode: code)
        }
    }
    
    fileprivate func pageInfoFromHeaders(_ headers: [AnyHashable: Any]) -> PageInfo? {
        guard let
            totalString = headers["X-Total"] as? String,
            let perPageString = headers["X-Per-Page"] as? String,
            let pageString = headers["X-Page"] as? String,
            let total = Int(totalString),
            let perPage = Int(perPageString),
            let page = Int(pageString)
            else { return nil }
        return PageInfo(number: page, size: perPage, total: total)
    }
    
}
