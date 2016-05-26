// JaymeExample
// Post.swift
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

struct Post: Identifiable {
    let id: Identifier
    let authorID: Identifier
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
        self.id = id
        self.authorID = authorID
        self.title = title
        self.abstract = abstract
        self.date = date
    }
    
    var dictionaryValue: [String: AnyObject] {
        return [
            "id": self.id,
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
