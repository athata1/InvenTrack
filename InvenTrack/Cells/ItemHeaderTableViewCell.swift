import UIKit

class ItemHeaderTableViewCell: UITableViewCell {
    static let identifier = "ItemHeaderTableViewCell"

    var item:Item!
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8  // Adjust the spacing between the labels
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title:"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating:"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func configure(item: Item) {
        self.item = item
        titleLabel.text = "Title: \(item.item_title)"
        ratingLabel.text = "Rating: \(item.item_review)"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Constants.secondaryColor
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(stackView)

        // Add labels to the stack view
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(ratingLabel)

        // Set up constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        ratingLabel.text = ""
    }
}
