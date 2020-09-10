//
//  CommentTableViewCell.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 10/09/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var textCommentView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContent(_ comment: CommentItem) {
        if let image = comment.user?.image {
            self.userImageView.image = image
        }
        
        self.nicknameLabel.text = comment.user?.nickname
        self.textCommentView.text = comment.textComment
    }

}
