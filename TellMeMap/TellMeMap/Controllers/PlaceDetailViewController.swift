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
    
    
    // MARK: - Properties
    var item: PlaceItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = item {
            self.title = place.name
            categoryLabel.text = place.category?.rawValue
            autorLabel.text = place.user?.nickname
            dateLabel.text = getDateFormat(date: place.date)
            descriptionTextView.text = place.message
            
            if let image = place.image {
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    @IBAction func actionDoubleTapLike(_ sender: UITapGestureRecognizer) {
        item?.likes! += 1
        animationLike()
        print("Likes en el lugar: \(String(describing: item?.likes))")
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
