// JaymeExample
// Post.swift
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

struct Post: Identifiable {
    let id: PostIdentifier
    let authorID: String
    let title: String
    let abstract: String
    let date: NSDate
}

extension Post: DictionaryInitializable, DictionaryRepresentable {
    
    init(dictionary: [String: AnyObject]) throws {
        guard let
            id = dictionary["id"] as? String,
            authorID = dictionary["author_id"] as? String,
            title = dictionary["title"] as? String,
            abstract = dictionary["abstract"] as? String,
            dateString = dictionary["date"] as? String,
            date = dateString.toDate()
            else { throw JaymeError.ParsingError }
        self.id = .Server(id)
        self.authorID = authorID
        self.title = title
        self.abstract = abstract
        self.date = date
    }
    
    var dictionaryValue: [String: AnyObject] {
        return [
            "id": "\(self.id)",
            "author_id": self.authorID,
            "title": self.title,
            "abstract": self.abstract,
            "date": self.date
        ]
    }
    
}

private extension String {
    
    func toDate() -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.dateFromString(self)
    }
    
}
