//
//  GameScene.swift
//  Pinball
//
//  Created by Cory Alder on 2016-08-16.
//  Copyright (c) 2016 Davander Mobile Corporation. All rights reserved.
//

import SpriteKit


enum GameType: UInt32 {
    case Ball = 1
    case Board = 2
    case Bumper = 4
}


class GameScene: SKScene {
    
    var startDate = NSDate()
    var score = 0
    
    // MARK: Pre-written code
    
    func createRamp(view: UIView) -> CGPath {
        let bPath = UIBezierPath()
        
        let rampStartV = CGPoint(x: view.frame.maxX - 30, y: 0 + view.frame.height/2)
        let rampStartS = self.convertPointFromView(rampStartV)
        
        let rampBottomV = CGPoint(x: view.frame.maxX - 30, y: view.frame.height)
        let rampBottomS = self.convertPointFromView(rampBottomV)
        
        let bottomRightV = CGPoint(x: view.frame.maxX, y: view.frame.maxY)
        let bottomRightS = self.convertPointFromView(bottomRightV)
        
        let startOFCurveV = CGPoint(x: view.frame.maxX, y: 0 + view.frame.width/2)
        let startOFCurveS = self.convertPointFromView(startOFCurveV)
        
        let centerOfArcV = CGPoint(x: view.frame.midX, y: 0 + view.frame.width/2)
        let centerOfArcS = self.convertPointFromView(centerOfArcV)
        let topOfArcS = self.convertPointFromView(CGPoint.zero)
        let radius = topOfArcS.y - centerOfArcS.y
        
        let bottomLeftV = CGPoint(x: 0, y: view.frame.maxY)
        let bottomLeftS = self.convertPointFromView(bottomLeftV)
        
        bPath.moveToPoint(rampStartS)
        bPath.addLineToPoint(rampBottomS)
        bPath.addLineToPoint(bottomRightS)
        bPath.addLineToPoint(startOFCurveS)
        bPath.addArcWithCenter(centerOfArcS, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI), clockwise: true)
        bPath.addLineToPoint(bottomLeftS)
        
        return bPath.CGPath
    }

    
    func ballStart(view: UIView) -> CGPoint {
        let ballStartV = CGPoint(x: view.frame.maxX - 15, y: view.frame.height-15)
        let ballStartS = self.convertPointFromView(ballStartV)
        return ballStartS
    }
    
    func randomBumper(view: UIView) -> SKShapeNode {
        
        let maxX = view.frame.maxX - 30
        let maxY = view.frame.maxY
        
        let randomX = CGFloat(arc4random_uniform(UInt32(maxX)))
        let randomY = CGFloat(arc4random_uniform(UInt32(maxY)))
        let randomRadius = CGFloat(arc4random_uniform(30))
        
        let gamePoint = self.convertPointFromView(CGPoint(x: randomX, y: randomY))
        
        let shape = SKShapeNode(circleOfRadius: randomRadius)
        shape.position = gamePoint
        shape.physicsBody = SKPhysicsBody(circleOfRadius: randomRadius)
        shape.physicsBody?.restitution = 0.8
        shape.physicsBody?.dynamic = false
        shape.lineWidth = 2
        
        return shape
    }

    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        
        let boardPath = createRamp(view)
        
        let board = SKShapeNode(path: boardPath)
        board.lineWidth = 3
        board.physicsBody = SKPhysicsBody(edgeChainFromPath: boardPath)
        
        board.physicsBody?.categoryBitMask = GameType.Board.rawValue
        self.addChild(board)

        let ball = SKShapeNode(circleOfRadius: 14)
        
        ball.lineWidth = 2
        ball.fillColor = UIColor.whiteColor()
        
        ball.position = self.ballStart(view)
            //CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        ball.physicsBody?.categoryBitMask = GameType.Ball.rawValue
        ball.physicsBody?.contactTestBitMask = GameType.Bumper.rawValue
        
        ball.name = "ball"
        self.addChild(ball)
        
        for _ in 0...10 {
            let bumper = randomBumper(view)
            bumper.physicsBody?.categoryBitMask = GameType.Bumper.rawValue
            self.addChild(bumper)
        }
        
        self.physicsWorld.contactDelegate = self
        
    }
    
    // MARK: Interaction
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        startDate = NSDate()
    }
   
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let interval = -startDate.timeIntervalSinceNow
        
        let vector = CGVectorMake(0, CGFloat(interval) * 20)
        let hitAction = SKAction.applyImpulse(vector, duration: 0.01)
        
        if let ball = self.childNodeWithName("ball") {
            ball.runAction(hitAction)
        }
    }
    
    // MARK: Update loop
    
    override func update(currentTime: CFTimeInterval) {
        if let ball = self.childNodeWithName("ball"), view = self.view {
            
            let ballStart = self.ballStart(view)
            
            if ball.position.y < ballStart.y {
                ball.position = ballStart
            }
        }
    }
    
}


extension GameScene: SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        score += 1000
        print("bing! \(score)")
    }
}



