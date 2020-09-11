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
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var textCommentView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Making circular the user image
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.bounds.width / 2
        
        // Deleting pading of textview
        self.textCommentView.textContainer.lineFragmentPadding = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setContent(_ comment: CommentItem) {
        if let image = comment.user?.image {
            self.userImageView.image = image
        }
        
        self.nicknameLabel.text = comment.user?.nickname
        self.userTypeLabel.text = comment.user?.typeUser?.rawValue
        self.textCommentView.text = comment.textComment
    }

}
