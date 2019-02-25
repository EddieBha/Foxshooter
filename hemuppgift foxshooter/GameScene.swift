//
//  GameScene.swift
//  hemuppgift foxshooter
//
//  Created by Eddie Agegnehu Kyrk on 2019-01-11.
//  Copyright © 2019 Eddie Agegnehu Kyrk. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    var cloud: SKSpriteNode?
    var foxShooter: SKSpriteNode?
    var background = SKSpriteNode(imageNamed: "background")
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var ground: SKSpriteNode?
    var left: SKSpriteNode?
    var right: SKSpriteNode?
    var leftButton: SKSpriteNode?
    var rightButton: SKSpriteNode?
    var shoot: SKSpriteNode?
    
    var score = 0
    var scoreLabel: SKLabelNode?
    var lives = 2
    var lifeLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var pointsLabel: SKLabelNode?
    var floatingPointsLabel: SKLabelNode?
    
    let foxCategory: UInt32 = 0x1 << 1
    let balloonCategory: UInt32 = 0x1 << 2
    let ballCategory: UInt32 = 0x1 << 5
    let boundsCategory: UInt32 = 0x1 << 4
    let cloudCategory: UInt32 = 0x1 << 6
    
    private var foxWalkingFrames: [SKTexture] = []
    private var balloonHitFrames: [SKTexture] = []
    
    var balloonTimeInterval: Double = 1.2
    var levelCounter: Int = 0
    var levelLabel: SKLabelNode?
    
    var balloonTimer: Timer?
    var cloudTimer: Timer? 
    
    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = true
        
        physicsWorld.contactDelegate = self
        
        right = childNode(withName: "rightButton") as? SKSpriteNode
        right?.zPosition = 5
        left = childNode(withName: "leftButton") as? SKSpriteNode
        left?.zPosition = 5
        shoot = childNode(withName: "shoot") as? SKSpriteNode
        shoot?.zPosition = 5
        background.zPosition = -1

        buildFox()
        addChild(background)
//
//
//        foxMoving1 = SKAction(named: "foxMoving1")
//        foxShooter.removeAllActions()
//
//               run(SKAction.repeatForever(
//                    SKAction.sequence([
//                        SKAction.wait(forDuration: 0.5)
//                        ])
//                ))
        startTimers(balloonTimeInterval: balloonTimeInterval)
        cloudTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            timer in
            self.createCloud()
        })
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == balloonCategory, contact.bodyB.categoryBitMask == ballCategory {
            score += 3
            balloonHit(sprite: contact.bodyA.node!, points: 3)
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == balloonCategory, contact.bodyA.categoryBitMask == ballCategory {
            score += 3
            balloonHit(sprite: contact.bodyB.node!, points: 3)
            contact.bodyA.node?.removeFromParent()
        }
       

        if contact.bodyA.categoryBitMask == foxCategory, contact.bodyB.categoryBitMask == balloonCategory {
        }
        if contact.bodyA.categoryBitMask == balloonCategory, contact.bodyB.categoryBitMask == foxCategory {
        }

      
        scoreLabel?.text = "SCORE        " + "\(score)"
        if lives != -1 {
            lifeLabel?.text = "LIVES  "+"\(lives)"
        } else {
            gameOver(score: score)
        }
        
        if score > 15, levelCounter == 0 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 50, levelCounter == 1 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 120, levelCounter == 2 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 200, levelCounter == 3 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
        if score > 300, levelCounter == 4 {
            levelCounter += 1
            levelUp(level : levelCounter)
        }
    }
    func createBalloon() {
        let balloons = ["balloon1", "balloon2", "balloon3", "balloon4", "balloon5"]
        let selector = rng(max: 5, min: 0)
        let balloon = SKSpriteNode(imageNamed: balloons[Int(selector - 1)])
        balloon.zPosition = 4
        balloon.physicsBody = SKPhysicsBody(rectangleOf: balloon.size)
        balloon.physicsBody?.affectedByGravity = false
        balloon.physicsBody?.categoryBitMask = balloonCategory
        balloon.physicsBody?.collisionBitMask = 0
        addChild(balloon)
        addBalloons(sprite: balloon)
        
    }
    
    func addBalloons(sprite: SKSpriteNode) {
        
        
            
            //bounds for spawn
            let maxX = size.width / 2 - sprite.size.width / 2
            let minX = -size.width / 2 + sprite.size.width
            
            //spawn position
            let range = maxX - minX
            let posX = maxX - CGFloat(arc4random_uniform(UInt32(range)))
            sprite.position = CGPoint(x: posX, y: size.height / 2 + sprite.size.height)
            
            //movement
            let moveLeft = SKAction.moveBy(x: -size.width/20 , y: -size.height/2.5, duration: 4)
            let moveRight = SKAction.moveBy(x: size.width/20 , y: -size.height/2.5, duration: 4)
            let selector = arc4random_uniform(4)
            let number = 4 - selector
            if number == 1 {
                sprite.run(SKAction.sequence([moveLeft, moveRight, SKAction.removeFromParent()]))
            }
            if number == 2 {
                sprite.run(SKAction.sequence([moveRight, moveLeft, SKAction.removeFromParent()]))
            }
            if number == 3 {
                sprite.run(SKAction.sequence([moveRight, moveRight, SKAction.removeFromParent()]))
            }
            if number == 4 {
                sprite.run(SKAction.sequence([moveLeft, moveLeft, SKAction.removeFromParent()]))
            }
            
        }
    
    
    func createCloud() {
        let selector = rng(max: 2, min: 0)
        if selector == 1 {
            cloud = SKSpriteNode(imageNamed: "cloudA")
        }
        if selector == 2 {
            cloud = SKSpriteNode(imageNamed: "cloudB")
        }
        cloud?.zPosition = 1
        cloud?.physicsBody = SKPhysicsBody(rectangleOf: (cloud?.size)!)
        cloud?.physicsBody?.affectedByGravity = false
        cloud?.physicsBody?.categoryBitMask = cloudCategory
        cloud?.physicsBody?.contactTestBitMask = cloudCategory
        cloud?.physicsBody?.collisionBitMask = 0
        addChild(cloud!)
        spawnCloud(sprite: cloud!)
    }
    func spawnCloud(sprite: SKSpriteNode) {
        
        //bounds for spawn
        let maxY = size.height / 2 - sprite.size.height / 2
        let minY = -size.height / 2 + 6 * sprite.size.height
        
        //spawn position
        let range = maxY - minY
        let posY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        sprite.position = CGPoint(x: size.width + sprite.size.width, y: posY)
        
        //movement
        let moveLeft = SKAction.moveBy(x: -size.width - 2 * sprite.size.width, y: 0, duration: 15)
        sprite.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func rng (max: Int, min: Int) -> Double {
        let max = max
        let min = min
        let range = max - min
        let number = Double(max) - Double(arc4random_uniform(UInt32(range)))
        return number
        
    }
    
    func getBalloonHitFrames() {
        let balloonAnimatedAtlas = SKTextureAtlas(named: "balloon")
        var exFrames: [SKTexture] = []
        let explosionTextureName = "balloon_explode"
        exFrames.append(balloonAnimatedAtlas.textureNamed(explosionTextureName))
        
        balloonHitFrames = exFrames
    }
    
    func balloonHit(sprite: SKNode, points: Int) {
        sprite.removeAllActions()
        sprite.physicsBody = nil
        let popSound = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
        let explode = SKAction.animate(with: balloonHitFrames,
                                       timePerFrame: 0.1,
                                       resize: false,
                                       restore: true)
        let seq = SKAction.sequence([popSound, explode, SKAction.removeFromParent()])
        
        sprite.run(seq, withKey: "balloonHit")
        
        showPoints(sprite: sprite, points: points)
        
    }
    
    func showPoints (sprite: SKNode, points: Int) {
        if points > 0 {
            floatingPointsLabel = SKLabelNode(text: "+\(points)")
        } else {
            floatingPointsLabel = SKLabelNode(text: "\(points)")
        }
        floatingPointsLabel?.position = sprite.position
        floatingPointsLabel?.zPosition = 11
        floatingPointsLabel?.fontName = "Helvetica Neue"
        floatingPointsLabel?.fontSize = 30
        addChild(floatingPointsLabel!)
        let goUp = SKAction.moveBy(x: 0, y: 30, duration: 1)
        floatingPointsLabel?.run(SKAction.sequence([goUp, SKAction.removeFromParent()]))
        
    }
    func gameOver(score: Int) {
        scene?.isPaused = true
        balloonTimer?.invalidate()
        cloudTimer?.invalidate()
        yourScoreLabel = SKLabelNode(text: "Your Score")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.zPosition = 11
        yourScoreLabel?.fontName = "Helvetica Neue"
        yourScoreLabel?.fontSize = 64
        yourScoreLabel?.numberOfLines = 0
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        pointsLabel = SKLabelNode(text: "\(score)")
        pointsLabel?.position = CGPoint(x: 0, y: 0)
        pointsLabel?.zPosition = 11
        pointsLabel?.fontName = "Helvetica Neue"
        pointsLabel?.fontSize = 150
        pointsLabel?.numberOfLines = 0
        if pointsLabel != nil {
            addChild(pointsLabel!)
        }
        
//        replayButton = SKSpriteNode(imageNamed: "playbutton")
//        replayButton?.position = CGPoint(x: 0, y: -150)
//        replayButton?.zPosition = 11
//        replayButton?.name = "replay"
//        addChild(replayButton!)
    }
    
//
//    func moveFox(_touches: Set<UITouch>) {
//    if let touch = _touches.first {
//        let nodeLocation = foxShooter.position
//        let touchPoint = touch.location(in:view)
//        let touchLocation = convertPoint(fromView: touchPoint)
//
//        if let foxAction = foxMoving1 {
//            foxShooter.run(foxAction)
//        }
//        let a = touchLocation.x - nodeLocation.x
//
//        let moveAction = SKAction.moveBy(x: a, y: 0, duration: 2)
//
//        foxShooter.run(moveAction)
//        /*foxShooter.run(moveAction, completion: {() -> Void in
//            self.foxShooter.removeAllActions()
//            self.foxShooter.texture = SKTexture(imageNamed: "fox.png")
//        })*/
//    }
    
    func moveFox(moveBy: CGFloat, forTheKey: String) {
        let moveAction = SKAction.moveBy(x: moveBy, y: 0, duration: 1)
        let repeatForEver = SKAction.repeatForever(moveAction)
        let seq = SKAction.sequence([moveAction, repeatForEver])
        foxShooter?.run(seq, withKey: forTheKey)
        animateFox()
        
        if forTheKey == "rightButton" {
            foxShooter?.xScale = abs((foxShooter?.xScale)!) * -1.0
        }
        if forTheKey == "leftButton" {
            foxShooter?.xScale = abs((foxShooter?.xScale)!) * 1.0
        }
        
    }
        func buildFox() {
            let foxAnimatedAtlas = SKTextureAtlas(named: "fox")
            var walkFrames: [SKTexture] = []
            
            let numImages = foxAnimatedAtlas.textureNames.count
            for i in 0...numImages - 1 {
                let foxTextureName = "fox\(i)"
                walkFrames.append(foxAnimatedAtlas.textureNamed(foxTextureName))
            }
            foxWalkingFrames = walkFrames
            let firstFrameTexture = foxWalkingFrames[0]
            foxShooter = childNode(withName: "foxShooter") as? SKSpriteNode
            foxShooter?.texture = firstFrameTexture
            foxShooter?.size = firstFrameTexture.size()
            
            foxShooter?.zPosition = 4
            foxShooter?.physicsBody?.usesPreciseCollisionDetection = true
            foxShooter?.physicsBody?.categoryBitMask = foxCategory
            foxShooter?.physicsBody?.collisionBitMask = boundsCategory
            ground = childNode(withName: "ground") as? SKSpriteNode
            ground?.physicsBody?.categoryBitMask = boundsCategory
            ground?.physicsBody?.collisionBitMask = foxCategory
            leftWall = childNode(withName: "leftWall") as? SKSpriteNode
            leftWall?.physicsBody?.categoryBitMask = boundsCategory
            leftWall?.physicsBody?.collisionBitMask = foxCategory
            rightWall = childNode(withName: "rightWall") as? SKSpriteNode
            rightWall?.physicsBody?.categoryBitMask = boundsCategory
            rightWall?.physicsBody?.collisionBitMask = foxCategory
        }
        
    func animateFox() {
        foxShooter?.run(SKAction.repeatForever(
            SKAction.animate(with: foxWalkingFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
                    withKey:"walkingFox")
        if foxShooter?.texture == nil {
            let atlas = SKTextureAtlas(named: "fox")
            let texture = atlas.textureNamed("fox0")
            foxShooter?.texture = texture
        }
    }


    func startTimers(balloonTimeInterval: Double) {
        balloonTimer = Timer.scheduledTimer(withTimeInterval: balloonTimeInterval, repeats: true, block: {
            timer in
            self.createBalloon()
        })
}
    func spawnBall(sprite: SKSpriteNode) {
        
        sprite.position = CGPoint(x: (foxShooter?.position.x)!, y: (foxShooter?.position.y)! - (foxShooter?.position.y)! / 2)
        
        let fire = SKAction.moveBy(x: 0, y: size.height, duration: 0.5)
        sprite.run(SKAction.sequence([fire, SKAction.removeFromParent()]))
        
    }
    func levelUp(level : Int) {
        
        levelLabel = SKLabelNode(text: "Level " + "\(levelCounter)")
        levelLabel?.position = CGPoint(x: size.width, y: 0)
        levelLabel?.zPosition = 11
        levelLabel?.fontName = "Helvetica Neue"
        levelLabel?.fontSize = 200
        if levelLabel != nil {
            addChild(levelLabel!)
        }
        spawnLabel(sprite: levelLabel!)
        balloonTimer?.invalidate()
        balloonTimeInterval -= 0.2
        startTimers(balloonTimeInterval: balloonTimeInterval)
        
    }
    func spawnLabel(sprite: SKLabelNode) {
        
        let dash1 = SKAction.moveTo(x: 0, duration: 0.8)
        let stop = SKAction.moveBy(x: 0, y: 0, duration: 1)
        let dash2 = SKAction.moveTo(x: -size.width, duration: 0.8)
        sprite.run(SKAction.sequence([dash1, stop, dash2, SKAction.removeFromParent()]))
        
    }
    
    


    func ballShooting() {
      
            let ball = SKSpriteNode(imageNamed: "ball")
            ball.zPosition = 4
            ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.categoryBitMask = ballCategory
            ball.physicsBody?.contactTestBitMask = balloonCategory
            ball.physicsBody?.collisionBitMask = 0
            addChild(ball)
            spawnBall(sprite: ball)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)
            
            if (touches.name == "rightButton") {
                foxShooter?.removeAction(forKey: "leftButton")
                moveFox(moveBy: 1000, forTheKey: "rightButton")
            
            }
            if (touches.name == "leftButton") {
                foxShooter?.removeAction(forKey: "rightButton")
                moveFox(moveBy: -1000, forTheKey: "leftButton")
              
            }
            if (touches.name == "shoot") {
                ballShooting()
            }
            if (touches.name == "shoot" && touches.name == "rightButton") {
                foxShooter?.removeAction(forKey: "leftButton")
                moveFox(moveBy: 1000, forTheKey: "rightButton")
                ballShooting()
               
            }
            if (touches.name == "shoot" && touches.name == "leftButton") {
                foxShooter?.removeAction(forKey: "rightButton")
                moveFox(moveBy: -1000, forTheKey: "leftButton")
                ballShooting()
            }
        }
        }
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
            
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touches = self.atPoint(location)
            
            
            if (touches.name == "rightButton") {
                foxShooter?.removeAction(forKey: "rightButton")
                foxShooter?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "leftButton") {
                foxShooter?.removeAction(forKey: "leftButton")
                foxShooter?.removeAction(forKey: "walkingFox")
            } else if (touches.name == "shoot"){
                
            }
        }
      
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
