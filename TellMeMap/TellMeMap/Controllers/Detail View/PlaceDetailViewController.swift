//
//  PlaceDetailViewController.swift
//  tellMeMap
//
//  Created by Julia García Martínez on 18/08/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likesView: UIImageView!
    @IBOutlet weak var numLikesLabel: UILabel!
    @IBOutlet var commentsTV: UITableView!
    
    @IBOutlet weak var heightTV: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addCommentStack: UIStackView!
    
    @IBOutlet weak var addCommentTextField: UITextField!
    
    
    // MARK: - Properties
    var item: PlaceItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentsTV.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // Detecting when keyboard will show to raise the text field
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
        
        if UserSessionSingleton.session.userItem.typeUser == UserType.neighbour {
            self.addCommentStack.isHidden = true
        }
        
        self.commentsTV.delegate = self
        self.commentsTV.dataSource = self
        
        setPlaceData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.commentsTV.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.commentsTV.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.commentsTV.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newValue = change![.newKey] {
                    let newSize = newValue as! CGSize
                    self.heightTV.constant = newSize.height
                }
            }
        }
    }
    
    
    // MARK: - Actions
    @IBAction func actionDoubleTapLike(_ sender: UITapGestureRecognizer) {
        if let i = item, let _ = i.likes  {
            i.likes! += 1
            UserSessionSingleton.session.userItem.addLikedPlace(i)
            CoreDataManager.sharedCDManager.updatePlace(i)
            numLikesLabel.text = "\(i.likes ?? 0)"
            animationLike()
        }
    }
    
    @IBAction func actionPostComment(_ sender: UIButton) {
        if let text = self.addCommentTextField.text, !text.isEmpty {
            let commentItem = CommentItem(user: UserSessionSingleton.session.userItem, textComment: text)
            item?.comments.append(commentItem)
            
            CloudKitManager.sharedCKManager.addComment(text: text, placeRecord: (item?.record)!) {
                finish in
                if finish {
                    CoreDataManager.sharedCDManager.saveComment(commentItem, idPlace: (self.item?.identifier)!)
                    DispatchQueue.main.async( execute: {
                        self.addCommentTextField.text = ""
                        self.commentsTV.reloadData()
                        self.dismissKeyboard()
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = frame.cgRectValue

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)

        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    
    // MARK: - Methods
    func setPlaceData() {
        if let place = item {
            self.title = place.name
            self.categoryLabel.text = place.category?.rawValue
            self.autorLabel.text = place.user?.nickname
            self.dateLabel.text = getDateFormat(date: place.date)
            self.descriptionTextView.text = place.message
            
            if let likes = place.likes {
                self.numLikesLabel.text = "\(likes)"
            }
            
            if UserSessionSingleton.session.userItem.isLikedPlace(place) {
                self.likesView.image = UIImage(systemName: "heart.fill")
            }
            
            if let image = place.image {
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
            
            item?.getPlaceComments({
                (success) in
                self.commentsTV.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                self.commentsTV.reloadData()
                place.comments.forEach({ (commentItem) in
                    CoreDataManager.sharedCDManager.saveComment(commentItem, idPlace: place.identifier!)
                })
            })
        }
    }
    
    func getDateFormat(date: Date?) -> String? {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        return (date != nil ? dataFormatter.string(from: date!) : nil)
    }
    
    func animationLike() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 1.0
        pulse.toValue = 1.15
        pulse.autoreverses = true
        pulse.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = 1
        animationGroup.animations = [pulse]
        
        self.likesView.layer.add(animationGroup, forKey: "pulse")
        
        UIView.transition(with: self.likesView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.likesView.image = UIImage(systemName: "heart.fill") },
                          completion: nil)
        
    }
}


extension PlaceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let item = item {
            return item.comments.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = item!.comments[indexPath.row]
        
        guard let newCell = tableView.dequeueReusableCell(withIdentifier: "idComment", for: indexPath) as? CommentTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        
        newCell.setContent(comment)
        newCell.selectionStyle = .none
        
        return newCell
    }
    
}
