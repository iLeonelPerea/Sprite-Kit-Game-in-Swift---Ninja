//
//  GameViewController.swift
//  shootingGame
//
//  Created by Leonel Roberto Perea Trejo on 11/11/14.
//  Copyright (c) 2014 Leonel Roberto Perea Trejo. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size) // initialice GameScene with the size of the view
        let skView = view as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}