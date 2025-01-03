//
//  GradientView.swift
//  Runner
//
//  Created by hoshizora-rin on 2025/1/2.
//

import UIKit
import SnapKit

class GradientLayer: CAGradientLayer, CAAnimationDelegate {
    let colorOne = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor
    let colorTwo = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
    let colorThree = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
    let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")

    var currentGradient = 0
    var gradientSet = [[CGColor]]()

    func animateGradient() {
        gradientChangeAnimation.fromValue = gradientSet[currentGradient]
        colors = gradientSet[currentGradient]
        
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        gradientChangeAnimation.duration = 5.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        add(gradientChangeAnimation, forKey: "moveAnimation")
    }

    func createGradientView() {
        gradientSet.append([colorOne, colorTwo])
        gradientSet.append([colorTwo, colorThree])
        gradientSet.append([colorThree, colorOne])

        colors = gradientSet[currentGradient]
        startPoint = CGPoint(x:0, y:0)
        endPoint = CGPoint(x:1, y:1)
        drawsAsynchronously = true
    }
    
    func removeAnimation() {
        removeAnimation(forKey: "moveAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            animateGradient()
        }
    }
}
