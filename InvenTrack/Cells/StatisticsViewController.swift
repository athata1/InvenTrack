import UIKit

class StatisticsViewController: UIViewController {

    var rating = 0.0
    var group: Group?
    var variables: [Variable] = []
    var statistics: [(String, Double)] = []
    var statItems: [Item] = []
    
    func configure(rating: Double, group: Group, variables: [Variable]) {
        self.rating = rating
        self.group = group
        self.variables = variables
    }

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constants.primaryColor
        tableView.sectionIndexColor = Constants.secondaryColor
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.primaryColor

        // Add the tableView to the view
        view.addSubview(tableView)

        // Set the tableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self

        // Register default cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ItemHeaderTableViewCell.self, forCellReuseIdentifier: ItemHeaderTableViewCell.identifier)

        // Set up constraints for the tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let group = self.group {
            self.statistics = DBManager.shared.findStatistics(rating: rating, group: group, variables: variables)
            self.statItems = DBManager.shared.getItemsByRating(id: group.group_id, rating: rating)
            print(statItems)
        }
    }

    // ... (other methods)

}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Only one section for now
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows is the count of statistics
        if (section == 0) {
            return statistics.count
        }
        else if (section == 1){
            return statItems.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Statistics"
        }
        if (section == 1) {
            return "Items"
        }
        return "Why Here?"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 50
        }
        if (indexPath.section == 1) {
            return 75
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            // Configure the cell with the statistics data
            let (title, value) = statistics[indexPath.row]
            cell.textLabel?.text = "AVG \(title): \(value)"
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = Constants.secondaryColor
            cell.textLabel?.textColor = .black
            
            return cell
        }
        else if (indexPath.section == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemHeaderTableViewCell.identifier, for: indexPath) as? ItemHeaderTableViewCell else {
                return UITableViewCell()
            }
            let item = statItems[indexPath.row]
            cell.configure(item: item)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell;
    }

    // Add any additional UITableViewDelegate methods if needed

}

