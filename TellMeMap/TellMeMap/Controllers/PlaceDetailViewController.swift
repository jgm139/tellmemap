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
    
    
    // MARK: - Properties
    var item: PlaceItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = item {
            self.title = place.name
            self.categoryLabel.text = place.category?.rawValue
            self.autorLabel.text = place.user?.nickname
            self.dateLabel.text = getDateFormat(date: place.date)
            self.descriptionTextView.text = place.message
            
            if let likes = place.likes {
                self.numLikesLabel.text = "\(likes)"
            }
            
            if UserSessionSingleton.session.user.isLikedPlace(place) {
                self.likesView.image = UIImage(systemName: "heart.fill")
            }
            
            if let image = place.image {
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    @IBAction func actionDoubleTapLike(_ sender: UITapGestureRecognizer) {
        if let i = item, let _ = i.likes  {
            i.likes! += 1
            UserSessionSingleton.session.user.addLikedPlace(i)
            numLikesLabel.text = "\(i.likes ?? 0)"
            animationLike()
        }
    }
    
    
    // MARK: - Methods
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
