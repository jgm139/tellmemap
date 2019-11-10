//
//  SignTableViewCell.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class SignTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var userName: UILabel?
    @IBOutlet weak var userPhoto: UIImageView?
    @IBOutlet weak var signTitle: UILabel!
    @IBOutlet weak var signDescription: UITextView!
    @IBOutlet weak var signDate: UILabel!
    
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(item: Sign) {
        //self.userName.text
        //self.userPhoto.image
        self.signTitle.text = item.name
        self.signDescription.text = item.description
        self.signDate.text = item.date
    }

}
