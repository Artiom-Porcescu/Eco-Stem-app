//
//  ViewPresentation.swift
//  Eco Stem
//
//  Created by Artiom Porcescu on 21.06.2023.
//

import UIKit

struct ViewPresentation {
    func animateIn(addView: UIView) {
        daggerButton.setTitle("", for: .normal)
        view.addSubview(addView)
        addView.center = self.view.center
        
        addView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.addView.alpha = 1
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3) {
            self.addView.alpha = 0
        } completion: { (success:Bool) in
            self.addView.removeFromSuperview()
        }
    }
}
