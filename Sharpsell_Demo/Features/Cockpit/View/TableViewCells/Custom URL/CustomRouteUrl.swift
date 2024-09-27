//
//  CustomRouteUrl.swift
//  Sharpsell_Demo
//
//  Created by Surya on 27/09/24.
//

import Foundation
import UIKit

class CustomRouteTableCell: UITableViewCell{
    //MARK: - Property Declarations
    static let reuseId = "CustomRouteTableCell"
    private let holderView = UIView()
//    private let contentLabel = UILabel()
    let customURLTextField: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Enter text"
            tf.borderStyle = .roundedRect
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()
    
     let openCustomRouteButton: UIButton = {
           let btn = UIButton(type: .system)
           btn.setTitle("Open Custom Route", for: .normal)
           btn.setTitleColor(.white, for: .normal)
           btn.titleLabel?.font = UIFont.systemFont(ofSize: 19)
           btn.backgroundColor = .systemOrange
           btn.layer.cornerRadius = 20
           btn.translatesAutoresizingMaskIntoConstraints = false
           return btn
       }()
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeFeaturedCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Custom methods
    private func makeFeaturedCellUI(){
        //Lable setup
        holderView.addSubview(customURLTextField)
        holderView.addSubview(openCustomRouteButton)
        
        //holderView setup
        holderView.translatesAutoresizingMaskIntoConstraints = false
        holderView.backgroundColor = .darkGray
        holderView.layer.cornerRadius = 20
        contentView.addSubview(holderView)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 140),
            holderView.heightAnchor.constraint(equalToConstant: 120),
            holderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            holderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            holderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            holderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            holderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            customURLTextField.heightAnchor.constraint(equalToConstant: 35),
            customURLTextField.topAnchor.constraint(equalTo: holderView.topAnchor, constant: 10),
            customURLTextField.leadingAnchor.constraint(equalTo: holderView.leadingAnchor, constant: 10),
            customURLTextField.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -10),

            openCustomRouteButton.heightAnchor.constraint(equalToConstant: 35),
            openCustomRouteButton.topAnchor.constraint(equalTo:  customURLTextField.bottomAnchor, constant: 10),
            openCustomRouteButton.leadingAnchor.constraint(equalTo: holderView.leadingAnchor, constant: 10),
            openCustomRouteButton.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -10),
//            openCustomRouteButton.bottomAnchor.constraint(equalTo: holderView.bottomAnchor, constant: 10),
        ])
    }
    
    
}
