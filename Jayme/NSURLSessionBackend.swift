// Jayme
// NSURLSessionBackend.swift
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
            guard let url = self.urlForPath(path) else {
                completion(.Failure(.BadURL))
                return
            }
            let requestNumber = Logger.sharedLogger.requestCounter
            Logger.sharedLogger.requestCounter += 1
            Logger.sharedLogger.log("Jayme: Request #\(requestNumber) | URL: \(url) | method: \(method.rawValue)")
            let request = self.requestWithURL(url, method: method)
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
    
    private func requestWithURL(URL: NSURL, method: HTTPMethodName) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = method.rawValue
        for header in self.configuration.httpHeaders {
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}
