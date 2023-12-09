import UIKit

class VariableViewController: UIViewController {

    // MARK: - Properties

    let variableNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Variable Name:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let variableNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter variable name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = Constants.primaryColor
        textField.borderStyle = .roundedRect
        
        textField.layer.borderColor = UIColor.black.cgColor // Set border color to black
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter variable name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray] // Set placeholder color to dark gray
        )
        
        return textField
    }()

    let variableTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Variable Type:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let variableTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Number", "Text"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = Constants.secondaryColor

        return segmentedControl
    }()

    var group: Group? = nil
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.secondaryColor
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Button Action
    @objc func saveButtonTapped() {
        // Add your code here to handle the save button tap
        // You can access the variable name and type using:
        let text  = variableNameTextField.text
        let type = variableTypeSegmentedControl.selectedSegmentIndex
        
        if (text == nil || text!.count == 0) {
            print("No text here")
            return
        }
        
        if let id = group?.group_id {
            let newVariable:Variable = DBManager.shared.createVariable(name: text!, type: Int64(type), group_id: id)!
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    func configure(group: Group) {
        self.group = group
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = Constants.primaryColor

        view.addSubview(variableNameLabel)
        view.addSubview(variableNameTextField)
        view.addSubview(variableTypeLabel)
        view.addSubview(variableTypeSegmentedControl)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            variableNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            variableNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            variableNameTextField.topAnchor.constraint(equalTo: variableNameLabel.bottomAnchor, constant: 8),
            variableNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            variableNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            variableTypeLabel.topAnchor.constraint(equalTo: variableNameTextField.bottomAnchor, constant: 20),
            variableTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            variableTypeSegmentedControl.topAnchor.constraint(equalTo: variableTypeLabel.bottomAnchor, constant: 8),
            variableTypeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            variableTypeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.topAnchor.constraint(equalTo: variableTypeSegmentedControl.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
