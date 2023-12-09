//
//  ItemViewController.swift
//  InvenTrack
//
//  Created by Akhil Thata on 12/3/23.
//

import UIKit

class ItemViewController: UIViewController {

    var group:Group? = nil
    var itemModels:[Item] = []
    var variables:[Variable] = []
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ItemHeaderTableViewCell.self, forCellReuseIdentifier: ItemHeaderTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
   }()
    
    func configure(with group: Group) {
        self.group = group
        variables = DBManager.shared.getVariables(id: group.group_id)
        itemModels = DBManager.shared.getItems(id: group.group_id)
        print(itemModels)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Items"
        view.backgroundColor = Constants.primaryColor
        // Do any additional setup after loading the view.
        
        let button1 = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .plain, target: self, action: #selector(openStatistics))
        self.navigationItem.rightBarButtonItem  = button1
        
        if let group_id = group?.group_id {
            variables = DBManager.shared.getVariables(id: group_id)
        }
        
        addSubviews()
    }
    
    @objc func openStatistics() {
        
        let alertController = UIAlertController(title: "Enter Decimal", message: nil, preferredStyle: .alert)

        // Add a text field to the alert for decimal input
        alertController.addTextField { textField in
            textField.placeholder = "Enter a decimal"
            textField.keyboardType = .decimalPad
        }

        var rating:Double = 0.0
        
        // Add the actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Retrieve the decimal value from the text field
            if let decimalString = alertController.textFields?.first?.text,
               let decimalValue = Double(decimalString) {
                // Use the decimalValue as needed
                print("Entered Rating Lower Bound: \(decimalValue)")
                rating = decimalValue
                let sVC = StatisticsViewController()
                if let group = self.group {
                    sVC.configure(rating: rating, group: group, variables: self.variables)
                }
                self.present(sVC, animated: true)
            } else {
                // Handle invalid input
                print("Invalid decimal input")
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        // Present the alert
        present(alertController, animated: true, completion: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemModels = DBManager.shared.getItems(id: group!.group_id)
        tableView.reloadData()
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == itemModels.count {
            return false
        }
        return true;
    }
    
    /*func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == itemModels.count) {
            
            if let g = group {
                let res = DBManager.shared.createItem(group: g, variables: variables)
                if let r = res {
                    itemModels.append(r.0)
                    let itemCreateVC = ItemCreateViewController()
                    itemCreateVC.configure(item: r.0, itemVariables: r.1)
                    navigationController?.pushViewController(itemCreateVC, animated: true)
                }
            }
        }
        else {
            /*let vc = ItemViewController()
            vc.configure(with: groupModels[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)*/
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == itemModels.count) {
            return 50
        }
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == itemModels.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "+"
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = Constants.secondaryColor
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemHeaderTableViewCell.identifier, for: indexPath) as? ItemHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(item: itemModels[indexPath.row])
            return cell
        }
        
    }
}


