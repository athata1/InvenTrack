//
//  GroupSchemaViewController.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/31/23.
//

import UIKit

class GroupSchemaViewController: UIViewController {

    var currentGroup: Group?;
    var currentIndex: Int?;
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(GroupTitleTableViewCell.self, forCellReuseIdentifier: GroupTitleTableViewCell.identifier)
       return tableView
   }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Constants.primaryColor
        
        //If we are editing, set of vc with previous data to be added
        //Else show appropriate data to create new data
        if let group = currentGroup {
        }
        else {
            currentGroup = DBManager.shared.addGroup(name: "New Group")
        }
        addSubviews()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Remove this line to use constraints
        // tableView.frame = view.bounds
        
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension GroupSchemaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 50
        }
        return 75
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Group"
        }
        return "Why am I here"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = Constants.tertiaryColor
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == groupModels.count) {
            let gsVC = GroupSchemaViewController()
            gsVC.currentIndex = indexPath.row
            gsVC.currentGroup = nil
            navigationController?.pushViewController(gsVC, animated: true)
        }
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupTitleTableViewCell.identifier, for: indexPath) as? GroupTitleTableViewCell else {
                        return UITableViewCell()
        }
        cell.configure(groupModel: currentGroup)
        return cell
    }
}
