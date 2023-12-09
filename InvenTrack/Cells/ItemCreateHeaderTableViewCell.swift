import UIKit

class ItemCreateHeaderTableViewCell: UITableViewCell {
    static let identifier = "ItemCreateHeaderTableViewCell"

    var item: Item!
    private var textChangeWorkItem: DispatchWorkItem?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title:"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 1
        return textField
    }()

    let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating:"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let ratingTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter rating"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .decimalPad
        textField.tag = 0
        return textField
    }()

    func configure(item: Item) {
        self.item = item
        ratingTextField.text = String(item.item_review)
        titleTextField.text = item.item_title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.secondaryColor
        contentView.clipsToBounds = true

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        titleTextField.delegate = self
        ratingTextField.delegate = self
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(ratingTextField)
    }
    
    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),

            titleTextField.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingLabel.widthAnchor.constraint(equalToConstant: 80),

            ratingTextField.topAnchor.constraint(equalTo: ratingLabel.topAnchor),
            ratingTextField.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            ratingTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ratingTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}


extension ItemCreateHeaderTableViewCell:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            // User pressed the return key
            return false
        }
        
        if (textField.tag == 0) {
            if let text = textField.text {
                let fullText = (text as NSString).replacingCharacters(in: range, with: string)
                if (fullText != "" && Double(fullText) == nil) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textChangeWorkItem?.cancel()
        
        // Create a new work item with a delay
        textChangeWorkItem = DispatchWorkItem { [weak self] in
            if let title = self?.titleTextField.text, let rating = self?.ratingTextField.text {
                var ratingCast:Double = 0.0
                if (rating == "") {
                    ratingCast = 0.0
                }
                else {
                    if let newRating = Double(rating) {
                        ratingCast = newRating
                    }
                }
                if let id = self?.item.item_id {
                    self?.item = DBManager.shared.modifyItemByPK(title: title, rating: ratingCast, pk: id)
                }
                    
            }
        }

        // Execute the work item after a delay (adjust the delay as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: textChangeWorkItem!)
    }
}
