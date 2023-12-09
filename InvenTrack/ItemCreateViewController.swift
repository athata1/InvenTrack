//
//  ItemCreateViewController.swift
//  InvenTrack
//
//  Created by Akhil Thata on 12/3/23.
//

import UIKit

class ItemCreateViewController: UIViewController {

    
    var item:Item!
    var itemVariables:[ItemVariables] = []
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ItemCreateHeaderTableViewCell.self, forCellReuseIdentifier: ItemCreateHeaderTableViewCell.identifier)
        tableView.register(ItemCreateVariableTableViewCell.self, forCellReuseIdentifier: ItemCreateVariableTableViewCell.identifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
   }()
    
    
    func configure(item:Item, itemVariables:[ItemVariables]) {
        self.item = item
        self.itemVariables = itemVariables
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Item"
        view.backgroundColor = Constants.primaryColor

        addSubviews()

    }
    
    func addSubviews() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Remove this line to use constraints
        
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension ItemCreateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Header Values"
        case 1:
            return "Variable Values"
        default:
            return "Why is this here"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else if (section == 1) {
            return itemVariables.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 150
        case 1:
            return 50
        default:
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemCreateHeaderTableViewCell.identifier, for: indexPath) as? ItemCreateHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(item: self.item)
            return cell
        }
        else if (indexPath.section == 1){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemCreateVariableTableViewCell.identifier, for: indexPath) as? ItemCreateVariableTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(itemVar: itemVariables[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}


