// Jayme
// NSURLSessionBackend.swift
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

/// Provides a Backend that connects to a server using HTTP REST requests via `NSURLSession`
public class NSURLSessionBackend: Backend {
    
    public typealias BackendReturnType = (NSData?, PageInfo?)
    public typealias BackendErrorType = JaymeError
    
    public init(configuration: NSURLSessionBackendConfiguration = NSURLSessionBackendConfiguration.defaultConfiguration,
         session: NSURLSession = NSURLSession.sharedSession(),
         responseParser: HTTPResponseParser = HTTPResponseParser()) {
        self.configuration = configuration
        self.session = session
        self.responseParser = responseParser
    }
    
    /// Returns a `Future` containing either:
    /// - A tuple with possible `NSData` relevant to the HTTP response and a possible `PageInfo` object if there is pagination-related info associated to the HTTP response
    /// - A `JaymeError` indicating which error is produced
    public func futureForPath(path: String, method: HTTPMethodName, parameters: [String: AnyObject]? = nil) -> Future<(NSData?, PageInfo?), JaymeError> {
        return Future() { completion in
            guard let request = try? self.requestWithPath(path, method: method, parameters: parameters) else {
                completion(.Failure(JaymeError.BadRequest))
                return
            }
            let requestNumber = Logger.sharedLogger.requestCounter
            Logger.sharedLogger.requestCounter += 1
            Logger.sharedLogger.log("Jayme: Request #\(requestNumber) | URL: \(request.URL!.absoluteString) | method: \(method.rawValue)")
            let task = self.session.dataTaskWithRequest(request) { data, response, error in
                let response: FullHTTPResponse = (data, response, error)
                let result = self.responseParser.parseResponse(response)
                switch result {
                case .Success(let maybeData, let pageInfo):
                    Logger.sharedLogger.log("Jayme: Response #\(requestNumber) | Success")
                    completion(.Success(maybeData, pageInfo))
                case .Failure(let error):
                    Logger.sharedLogger.log("Jayme: Response #\(requestNumber) | Failure, error: \(error)")
                    completion(.Failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    
    private let configuration: NSURLSessionBackendConfiguration
    private let session: NSURLSession
    private let responseParser: HTTPResponseParser
    
    private var baseURL: NSURL? {
        return NSURL(string: self.configuration.basePath)
    }
    
    private func urlForPath(path: String) -> NSURL? {
        return self.baseURL?.URLByAppendingPathComponent(path)
    }
    
    private func requestWithPath(path: String, method: HTTPMethodName, parameters: [String: AnyObject]?) throws -> NSURLRequest {
        guard let url = self.urlForPath(path) else {
            throw JaymeError.BadRequest
        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        for header in self.configuration.httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        guard let params = parameters else {
            return request
        }
        do {
            let body = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            request.HTTPBody = body
        } catch {
            throw JaymeError.BadRequest
        }
        return request
    }
    
}
