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
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        self.loadUsers()
    }
    
    // MARK: - Private
    
    fileprivate var users = [User]()
    fileprivate var selectedUser: User?
    
    fileprivate func loadUsers() {
        UserRepository().readAll().start { result in
            switch result {
            case .success(let users):
                self.users = users
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlertController(for: error)
            }
        }
    }
    
    fileprivate func showAlertController(for error: JaymeError) {
        let message = self.description(for: error)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func description(for error: JaymeError) -> String {
        switch error {
        case .serverError(let code):
            return "Server Error (code: \(code))"
        case .other(let innerError):
            return innerError.localizedDescription
        default:
            return "Unexpected error"
        }
    }
    
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.Identifier) as! UserTableViewCell
        cell.user = self.user(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = self.user(at: indexPath)
        self.performSegue(withIdentifier: "ShowUserDetail", sender: self)
    }
    
    fileprivate func user(at indexPath: IndexPath) -> User {
        return self.users[(indexPath as NSIndexPath).row]
    }
    
}

extension UsersViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? UserDetailViewController else {
            return
        }
        controller.user = self.selectedUser!
    }
    
}
