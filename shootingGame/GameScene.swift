//
//  GameScene.swift
//  shootingGame
//
//  Created by Leonel Roberto Perea Trejo on 11/11/14.
//  Copyright (c) 2014 Leonel Roberto Perea Trejo. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b01
    static let Projectile: UInt32 = 0b10
}

var backgroundMusicPlayer: AVAudioPlayer!
var monstersKilledToWin = 50
var monstersDestroyed = 0
var maxProjectile = 7
var countProjectile = 0
var live = 10
let lblLives = SKLabelNode(fontNamed: "Chalkduster")
let lblMonsters = SKLabelNode(fontNamed: "Chalkduster")
let lblProjectiles = SKLabelNode(fontNamed: "Chalkduster")

// Play music endlessly
func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

// MARK: - Overloadin Functions
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override init(size: CGSize) {
        super.init(size: size)
        monstersDestroyed = 0
        countProjectile = 0
        live = 5
    }
    
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        // Set background
        var bgImage = SKSpriteNode(imageNamed: "background.jpg")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.alpha = (0.5)
        addChild(bgImage)
        
        // Reset Labels
        lblLives.removeFromParent()
        lblMonsters.removeFromParent()
        lblProjectiles.removeFromParent()
        
        // Set properties for live label
        lblLives.text = "\(live) lives"
        lblLives.fontSize = 20
        lblLives.fontColor = SKColor.whiteColor()
        lblLives.position = CGPoint(x:  size.width * 0.1, y: size.height * 0.1)
        
        // Set properties for monster label
        lblMonsters.text = "\(monstersKilledToWin - monstersDestroyed) kills to win"
        lblMonsters.fontSize = 20
        lblMonsters.fontColor = SKColor.whiteColor()
        lblMonsters.position = CGPoint(x:  size.width * 0.6, y: size.height * 0.1)
        
        // Set properties for projectile label
        lblProjectiles.text = "\(maxProjectile - countProjectile) stars"
        lblProjectiles.fontSize = 20
        lblProjectiles.fontColor = SKColor.whiteColor()
        lblProjectiles.position = CGPoint(x:  size.width * 0.3, y: size.height * 0.9)
        
        // Set background audio
        playBackgroundMusic("background-music-aac.caf")
                
        // Set position for the player
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        
        // Add player to the scene
        addChild(player)
        
        // Set physics world
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        // Add monster each second
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(NSTimeInterval(random(min: CGFloat(0.3), max: CGFloat(1.0))))
                ])
            ))
        
        // Add labels to scene
        addChild(lblLives)
        addChild(lblMonsters)
        addChild(lblProjectiles)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Create a physics body for the sprite
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        // Indicates that physics engine will not control the movement
        monster.physicsBody?.dynamic = true
        // Set category for monster
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        // Notify when interset with which category
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        // Set Default
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        monster.alpha = (random(min: 0.2, max: 1.0))
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(1.0), max: CGFloat(3.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        let actionMonsterAttack = SKAction.playSoundFileNamed("monster-punch.caf", waitForCompletion: false)
        
        // Define lost action
        let loseAction = SKAction.runBlock() {
            live--
            lblLives.text = "\(live) lifes"
            if (live == 0){
                // Set audio for shooting
                monstersDestroyed = 0
                live = 0
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }

        // Define action for the game
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMonsterAttack]))
    }
    
    // Delegate of SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        // Set bodies for moster and projectile
        var monsterBody = (contact.bodyA.categoryBitMask == PhysicsCategory.Monster) ? contact.bodyA :contact.bodyB;
        var projectileBody = (contact.bodyA.categoryBitMask == PhysicsCategory.Projectile) ? contact.bodyA :contact.bodyB;
        
        // Check if monster and projectile have a correct category
        if ((monsterBody.categoryBitMask == PhysicsCategory.Monster) && projectileBody.categoryBitMask == PhysicsCategory.Projectile){
            // Call function that remove bodies
            var monster:SKSpriteNode = monsterBody.node as SKSpriteNode
            var projectile:SKSpriteNode = projectileBody.node as SKSpriteNode
            
            // Initialice spark emmitter
            let sparkEmmiter = SKEmitterNode(fileNamed: "particleSmoke")
            
            // Set properties for particle
            sparkEmmiter.position = monster.position
            sparkEmmiter.name = "sparkEmmitter"
            sparkEmmiter.zPosition = 1
            sparkEmmiter.targetNode = self
            sparkEmmiter.particleLifetime = 2
            sparkEmmiter.numParticlesToEmit = 1000
            sparkEmmiter.particleSize = monster.size
            
            // Add particle emmiter
            self.addChild(sparkEmmiter)
            
            // Remove particle emmiter
            runAction(SKAction.sequence([
                SKAction.waitForDuration(0.45),
                SKAction.runBlock() {
                    // Remove Spark Emmiter
                    sparkEmmiter.removeFromParent()
                }
                ]))
            
            // if exist Monster Body, delete it
            if ((monsterBody) != nil){
                // Increase monster destroyed
                monstersDestroyed++
                lblMonsters.text = "\(monstersKilledToWin - monstersDestroyed) kills to win"
                // Set audio for kill
                runAction(SKAction.playSoundFileNamed("strike.caf", waitForCompletion: false))
                monster.removeFromParent()
            }
            // if exist Monster Body, delete it
            if (projectileBody != nil){
                countProjectile--
                projectile.removeFromParent()
            }

            // If destroy 30 monster win the game
            if (monstersDestroyed >= monstersKilledToWin) {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: true)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if (countProjectile <= maxProjectile){
            
            // Choose one of the touches to work with
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            
            // Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player.position
            
            // Determine offset of location to projectile
            let offset = touchLocation - projectile.position
            
            // Bail out if you are shooting down or backwards (real ninjas don’t look back!)
            if (offset.x < 0) { return }
            
            // Set audio for shooting
            runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // Rotate projectile every 0.25 second endlessly
            projectile.runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.rotateByAngle(CGFloat(3.14), duration: NSTimeInterval(0.10))
                    ])
                ))
            
            // OK to add now - you've double checked position
            addChild(projectile)
            
            // Update quantity projectiles
            countProjectile++
            
            // Get the direction of where to shoot
            let direction = offset.normalized()
            
            // Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1024
            
            // Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 1.5)
            let actionMoveDone = SKAction.runBlock(){
                projectile.removeFromParent()
                countProjectile--
            }
            
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
        // Reflesh lbl
        lblProjectiles.text = "\(maxProjectile - countProjectile) stars"
    }
    
    // Implementation for a error
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
