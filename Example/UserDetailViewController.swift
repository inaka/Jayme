// JaymeExample
// UserDetailViewController.swift
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

import UIKit

class UserDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var user: User! {
        didSet {
            self.title = "\(user.name)'s Posts"
            self.loadPosts()
        }
    }

    // MARK: - Private
    
    private var posts = [Post]()
    
    private func loadPosts() {
        let future = PostRepository().findPostsForUser(self.user)
        future.start { result in
            switch result {
            case .Success(let posts):
                self.posts = posts
                self.tableView.reloadData()
            case .Failure(let error):
                self.showAlertControllerForError(error)
            }
        }
    }
    
    private func showAlertControllerForError(error: JaymeError) {
        let message = self.descriptionForError(error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func descriptionForError(error: JaymeError) -> String {
        switch error {
        case .ServerError(let code):
            return "Server Error (code: \(code))"
        case .Other(let nsError):
            return nsError.localizedDescription
        default:
            return "Unexpected error"
        }
    }
    
}

extension UserDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostTableViewCell.Identifier) as! PostTableViewCell
        cell.post = self.posts[indexPath.row]
        return cell
    }
    
}
