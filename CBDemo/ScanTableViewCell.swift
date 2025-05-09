//
//  ScanTableViewCell.swift
//  CBDemo
//
//  Created by 이원빈 on 5/8/25.
//

import UIKit

class ScanTableViewCell: UITableViewCell {
    private let peripheralName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePeripheralName(name: String?) {
        guard name != nil else { return }
        peripheralName.text = name
    }
    
    private func setupLayout() {
        contentView.addSubview(peripheralName)
        
        NSLayoutConstraint.activate([
            peripheralName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            peripheralName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            peripheralName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            peripheralName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

