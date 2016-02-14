//
//  StudentTableViewCell.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class StudentLocationCell: UITableViewCell {

    @IBOutlet weak var pinView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor(patternImage: UIImage(named: "school")!)
    }
}
