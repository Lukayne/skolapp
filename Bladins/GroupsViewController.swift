//
//  GroupsViewController.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-09-13.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import Firebase

protocol GroupsDelegate: class {
    var groupsTableView: UITableView! { get }
    var me: User? { get }
}

class GroupsViewController: DefaultViewController, UITableViewDelegate, GroupsDelegate {
    
    @IBOutlet var groupsTableView: UITableView!
    
    var groupsDataSource: GroupsDataSource?
    var me: User?
    var selectedGroups: [String]? {
        didSet {
            groupsDataSource?.selectedGroups = selectedGroups
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Mina grupper"
        
        groupsDataSource = GroupsDataSource()
        groupsDataSource?.delegate = self
        
        groupsTableView.delegate = self
        groupsTableView.dataSource = groupsDataSource
        
        selectedGroups = me?.groupIds ?? [String]()
        
    }
    
    @IBAction func go(_ sender: DefaultButton) {
        me?.groupIds = selectedGroups
        me?.updateGroups(completion: { (success, response, error) in
            if let err = error {
                print(err)
            }
            if let navigation = self.navigationController as? NavigationController {
                navigation.popViewController(animated: true)
                return
            } else {
                // GO TO HOMEVIEWCONTROLLER
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                appDelegate.switchToMain(userId: self.me!.id!, completion: { (success, response, error) in
                    guard success, error == nil else {
                        print(error ?? "No success")
                        return
                    }
                    self.dismiss(animated: false, completion: nil)
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard   let cell = tableView.cellForRow(at: indexPath) as? GroupTableViewCell,
                selectedGroups != nil else {
            return
        }
        guard let group = cell.group else {
            return
        }
        if cell.selectedGroup == true {
            cell.selectedGroup = false
            selectedGroups! = selectedGroups!.filter { $0 != group.id }
        } else {
            cell.selectedGroup = true
            selectedGroups!.append(group.id)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}

class GroupsDataSource: NSObject, UITableViewDataSource {
    
    var delegate: GroupsDelegate? {
        didSet {
            getGroups { (success, response, error) in
                guard success, let groups = response as? [Group] else {
                    print(error ?? "Error! Failed to get groups")
                    return
                }
                self.groups = groups
            }
        }
    }
    
    var groups: [Group]? {
        didSet {
            delegate?.groupsTableView.reloadData()
        }
    }
    
    var selectedGroups: [String]? {
        didSet {
            delegate?.groupsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupTableViewCell
        cell.group = groups![indexPath.row]
        for selectedGroup in selectedGroups! {
            if cell.group?.id == selectedGroup {
                cell.selectedGroup = true
            }
        }
        return cell
    }
    
    func getGroups(completion: @escaping (Bool, Any?, Error?) -> Void) {
        guard delegate?.me != nil else {
            completion(false, nil, nil)
            return
        }
        let ref = Database.database().reference()
        ref.child("/schools/\(delegate!.me!.school!.name!)/groups").observeSingleEvent(of: .value, with: { (snapshot) in
            var groups = [Group]()
            if let entries = snapshot.valueInExportFormat() as? NSDictionary {
                for entry in entries {
                    if  let id = entry.key as? String,
                        let data = entry.value as? NSDictionary {
                        if let group = Group(id: id, data: data) {
                            groups.append(group)
                        }
                    }
                }
                groups = groups.sorted { return $0.memberCount > $1.memberCount }
                completion(true, groups, nil)
            } else {
                completion(false, nil, nil)
            }
        })
    }
}
