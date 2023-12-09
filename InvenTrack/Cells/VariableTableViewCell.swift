//
//  VariableTableViewCell.swift
//  InvenTrack
//
//  Created by Akhil Thata on 11/26/23.
//

import UIKit

protocol textUpdateDelegate: AnyObject {
    func updateText(atIndex index: Int, text: String)
}

class VariableTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = "VariableTableViewCell"
    
    var variable: Variable?
    var currentIndex: Int?
    
        
    let variableTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1;
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label;
    }()
    
    let variableTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1;
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label;
    }()
    
    
    func addSubviews() {
        contentView.addSubview(variableTitleLabel)
        contentView.addSubview(variableTypeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let typeLabelWidth = variableTypeLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: variableTypeLabel.height)).width
                
        for c in variableTypeLabel.constraints { variableTypeLabel.removeConstraint(c) }
        for c in variableTitleLabel.constraints { variableTypeLabel.removeConstraint(c) }
        NSLayoutConstraint.activate([
            variableTypeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            variableTypeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            variableTypeLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),
            variableTypeLabel.widthAnchor.constraint(equalToConstant: typeLabelWidth)
        ])
        NSLayoutConstraint.activate([
            variableTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            variableTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            variableTitleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),
            variableTitleLabel.trailingAnchor.constraint(equalTo: variableTypeLabel.leadingAnchor,constant: -10)
            
        ])
        
    }
    
    func configure(variable:Variable, index: Int) {
        self.variable = variable
        self.currentIndex = index
        variableTypeLabel.text = variable.variable_type == 0 ? "Number" : "Text"
        variableTitleLabel.text = variable.variable_name
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.secondaryColor
        contentView.clipsToBounds = true

        addSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        variable = nil
        currentIndex = -1
        variableTypeLabel.text = ""
        variableTitleLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
