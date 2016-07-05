// JaymeExample
// UsersViewController.swift
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

class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUsers()
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.loadUsers()
    }
    
    // MARK: - Private
    
    private var users = [User]()
    private var selectedUser: User?
    
    private func loadUsers() {
        UserRepository().findAll().start { result in
            switch result {
            case .Success(let users):
                self.users = users
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

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserTableViewCell.Identifier) as! UserTableViewCell
        cell.user = self.userAtIndexPath(indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedUser = self.userAtIndexPath(indexPath)
        self.performSegueWithIdentifier("ShowUserDetail", sender: self)
    }
    
    private func userAtIndexPath(indexPath: NSIndexPath) -> User {
        return self.users[indexPath.row]
    }
    
}

extension UsersViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let controller = segue.destinationViewController as? UserDetailViewController else {
            return
        }
        controller.user = self.selectedUser!
    }
    
}
