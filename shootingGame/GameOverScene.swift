//
//  GameOverScene.swift
//  shootingGame
//
//  Created by Leonel Roberto Perea Trejo on 11/11/14.
//  Copyright (c) 2014 Leonel Roberto Perea Trejo. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var seizeWindow = CGSize(width: 0,height: 0)
    
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        // Set sound for Win/Lose
        runAction(SKAction.playSoundFileNamed("gong-hit.caf", waitForCompletion: false))
        
        // Set Background
        backgroundColor = SKColor.whiteColor()
        
        // Define Messages
        var message = won ? "You Won!" : "You Lose :["
        
        // Set Font Name
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        seizeWindow = size
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // Set audio for shooting
        // Set sequence actions
        runAction(SKAction.sequence([
            SKAction.runBlock() {
            // Set transition for Scene
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: self.seizeWindow)
            self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
    
    // Implementation for a error
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}