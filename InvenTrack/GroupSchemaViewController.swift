//
//  GroupSchemaViewController.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/31/23.
//

import UIKit

class GroupSchemaViewController: UIViewController, textUpdateDelegate {

    var currentGroup: Group?;
    var currentIndex: Int?;
    var currentVariables: [Variable] = []
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(GroupTitleTableViewCell.self, forCellReuseIdentifier: GroupTitleTableViewCell.identifier)
        tableView.register(VariableTableViewCell.self, forCellReuseIdentifier: VariableTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = Constants.primaryColor
       return tableView
   }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Constants.primaryColor
        title = "Template"
        
        currentVariables = []
        //If we are editing, set of vc with previous data to be added
        //Else show appropriate data to create new data
        if currentGroup == nil {
            currentGroup = DBManager.shared.addGroup(name: "New Group")
        }
        if let group_id = currentGroup?.group_id {
            currentVariables = DBManager.shared.getVariables(id: group_id)
        }
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let group_id = currentGroup?.group_id {
            currentVariables = DBManager.shared.getVariables(id: group_id)
            tableView.reloadData()
        }
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
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
    
    func updateText(atIndex index: Int, text: String) {
        currentVariables[index].variable_name = text
    }
    
}

extension GroupSchemaViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return currentVariables.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 50
        }
        else if indexPath.section == 1{
            if (indexPath.row == currentVariables.count) {
                return 50
            }
            return 50
        }
        return 50
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Group"
        }
        else if section == 1 {
            return "Variables"
        }
        return "Why am I here"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = Constants.tertiaryColor
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && indexPath.row == currentVariables.count) {
            if let group = currentGroup {
                let variableVC = VariableViewController()
                variableVC.configure(group: group)
                self.navigationController?.pushViewController(variableVC, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupTitleTableViewCell.identifier, for: indexPath) as? GroupTitleTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(groupModel: currentGroup)
            return cell
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == currentVariables.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = "+"
                cell.textLabel?.textAlignment = .center
                cell.backgroundColor = Constants.secondaryColor
                return cell
            }
            else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: VariableTableViewCell.identifier, for: indexPath) as? VariableTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(variable: currentVariables[indexPath.row], index: indexPath.row)
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell;
        
    }
}
