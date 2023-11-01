//
//  GroupTitleTableViewCell.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/31/23.
//

import UIKit

class GroupTitleTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "GroupTitleTableViewCell"
    
    var group: Group?
    
    private var textChangeWorkItem: DispatchWorkItem?
    
    let groupTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1;
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title: "
        return label;
    }()
    
    let groupTextView: TextField = {
        let textView = TextField()
        textView.backgroundColor = Constants.primaryColor
        textView.tintColor = Constants.tertiaryColor
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16) // Adjust the font size as needed
        
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.secondaryColor
        contentView.clipsToBounds = true
        
        addSubviews()
    }
    
    func addSubviews() {
        contentView.addSubview(groupTitleLabel)
        contentView.addSubview(groupTextView)
        groupTextView.delegate = self
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleConstraints = [
            groupTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            groupTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor), // Center vertically
            groupTitleLabel.widthAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(titleConstraints)
        
        let textViewConstraints = [
            groupTextView.leadingAnchor.constraint(equalTo: groupTitleLabel.trailingAnchor, constant: 5),
            groupTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            groupTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupTextView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.50)
        ]
        NSLayoutConstraint.activate(textViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(groupModel: Group?) {
        group = groupModel

        if let group = group {
            groupTextView.text = group.group_title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        groupTextView.text = ""
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
            if let group = self?.group {
                if let text = textField.text {
                    self?.group = DBManager.shared.modifyGroupNameByPK(name: text, pk: group.group_id)
                }
            }
        }

        // Execute the work item after a delay (adjust the delay as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: textChangeWorkItem!)
    }
}
