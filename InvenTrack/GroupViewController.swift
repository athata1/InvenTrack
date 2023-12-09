//
//  ViewController.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/29/23.
//

import UIKit

class GroupViewController: UIViewController {

     var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var groupModels: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups"
        view.backgroundColor = Constants.primaryColor
        getGroups()
        addSubviews()
        
    }
    func getGroups() {
        groupModels = DBManager.shared.getGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGroups()
        tableView.reloadData()
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }


}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupModels.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == groupModels.count {
            return false
        }
        return true;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let data = self.groupModels[indexPath.row]
            let success:Bool = DBManager.shared.deleteGroupByPK(pk: data.group_id)
            if success {
                self.groupModels.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            let data = self.groupModels[indexPath.row]
            let gsVC = GroupSchemaViewController()
            gsVC.currentIndex = indexPath.row
            gsVC.currentGroup = data
            self.navigationController?.pushViewController(gsVC, animated: true)
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [edit,delete])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == groupModels.count) {
            let gsVC = GroupSchemaViewController()
            gsVC.currentIndex = indexPath.row
            gsVC.currentGroup = nil
            navigationController?.pushViewController(gsVC, animated: true)
        }
        else {
            let vc = ItemViewController()
            vc.configure(with: groupModels[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == groupModels.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "+"
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = Constants.secondaryColor
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = groupModels[indexPath.row].group_title
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = Constants.secondaryColor
            return cell
        }
        
    }
}
