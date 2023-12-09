//
//  GroupTitleTableViewCell.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/31/23.
//

import UIKit

class ItemCreateVariableTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "ItemCreateVariableTableViewCell"
    
    var itemVar: ItemVariables!
    
    private var textChangeWorkItem: DispatchWorkItem?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1;
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title: "
        return label;
    }()
    
    var titleTextView: TextField = {
        let textView = TextField()
        textView.backgroundColor = Constants.primaryColor
        textView.placeholder = "Enter value"
        textView.tintColor = Constants.tertiaryColor
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16) // Adjust the font size as needed
        textView.attributedPlaceholder = NSAttributedString(
            string: "Enter variable name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray] // Set placeholder color to dark gray
        )
        return textView
    }()
    
    func configure(itemVar: ItemVariables) {
        self.itemVar = itemVar
        titleTextView.text = itemVar.iv_text
        let variable: Variable = DBManager.shared.getVariable(pk: itemVar.iv_variable)!
        titleLabel.text = variable.variable_name
        if (variable.variable_type == 0) {
            titleTextView.keyboardType = .decimalPad
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.secondaryColor
        contentView.clipsToBounds = true
        
        addSubviews()
    }
    
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextView)
        titleTextView.delegate = self
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor), // Center vertically
            titleLabel.widthAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(titleConstraints)
        
        let textViewConstraints = [
            titleTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 5),
            titleTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.50)
        ]
        NSLayoutConstraint.activate(textViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleTextView.text = ""
        titleLabel.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            // User pressed the return key
            return false
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textChangeWorkItem?.cancel()
        
        // Create a new work item with a delay
        textChangeWorkItem = DispatchWorkItem { [weak self] in
            if let text = textField.text {
                if let id = self?.itemVar.iv_id {
                    self?.itemVar = DBManager.shared.modifyItemVariableByPK(text: text, pk: id)
                }
            }
        }

        // Execute the work item after a delay (adjust the delay as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: textChangeWorkItem!)
    }
}

