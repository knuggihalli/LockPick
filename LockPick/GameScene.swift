//
//  GameScene.swift
//  LockPick
//
//  Created by Kavun Nuggihalli on 4/15/16.
//  Copyright (c) 2016 ConsiderCode LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var circle = SKSpriteNode()
    var person = SKSpriteNode()
    var dot = SKSpriteNode()
    var gdot = SKSpriteNode();
    
    var path = UIBezierPath()
    var game_started = Bool()
    var moving_cw = Bool()
    
    //intersects for dots
    var intersect = false
    var gintersect = false
    
    var speed_lim = 200
    var score = 0
    
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode();
    var highscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    
    override func didMoveToView(view: SKView) {
        loadView()
    }

    func loadView(){
        circle = SKSpriteNode(imageNamed: "circle")
        circle.size = CGSize(width: 300, height: 300)
        circle.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(circle)
        
        person = SKSpriteNode(imageNamed: "person")
        person.size = CGSize(width: 40, height: 7)
        person.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 120)
        person.zRotation = 3.14/2
        person.zPosition = 2.0
        self.addChild(person)
        
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 50
        scoreLabel.text = String(score)
        scoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2-20)
        self.addChild(scoreLabel)
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
        {
            // app already launched
            
            //The line below is used to reset the high score
            //NSUserDefaults.standardUserDefaults().setInteger(score, forKey:"highscore")
        }
        else
        {
            // This is the first launch ever Put a tutorial here 
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey:"highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        highScoreLabel.fontColor = UIColor.blackColor()
        highScoreLabel.fontSize = 35
        highScoreLabel.text = "High Score: " + String(highscore)
        highScoreLabel.position = CGPoint(x: self.frame.width/2 , y: self.frame.height-200)
        self.addChild(highScoreLabel)
        
        self.scene?.backgroundColor = UIColor.whiteColor()
    
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(GameScene.addGDot), userInfo: nil, repeats: true)
        
        addDot()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if game_started == false{
            moveClockWise()
            moving_cw = true
            game_started = true
            
        }else if game_started == true{
          
            if moving_cw == true{
                moveCounterClockWise()
                moving_cw = false
            }else if moving_cw == false{
                moveClockWise()
                moving_cw = true
            }
            dotTouched()
        }
    }
    
    //dot touched methods
    func dotTouched(){
        if intersect == true{
            dot.removeFromParent()
            if(speed_lim < 500){
                speed_lim = speed_lim + 25;
            }
            score = score+1
            addDot()
            addGDot()
            let action = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
            let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
            self.scene?.runAction(SKAction.sequence([action,action2]))
            intersect = false
        }else if intersect == false{
            died()
        }
    }

   
    func died(){
        self.removeAllChildren()
        let action = SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.2)
        let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
        self.scene?.runAction(SKAction.sequence([action,action2]))
        moving_cw = false
        intersect = false
        game_started = false
        speed_lim = 200;
        
        let savedScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        if score > savedScore{
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey:"highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        score = 0
        self.loadView()
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        scoreLabel.text = String(score)
        highscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        highScoreLabel.text = "High Score: " + String(highscore)

        //what happens for regualr red dots
        if person.intersectsNode(dot){
            intersect = true;
        }else{
            if intersect == true{
                if person.intersectsNode(dot) == false{
                    died()
                }
            }
        }
        
        //what happenes for a green dot
        if person.intersectsNode(gdot){
            gdot.removeFromParent()
            let action = SKAction.colorizeWithColor(UIColor.yellowColor(), colorBlendFactor: 1.0, duration: 0.2)
            let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
            self.scene?.runAction(SKAction.sequence([action,action2]))
        }else{
            if gintersect == true{
                if person.intersectsNode(gdot) == false{
                  gdot.removeFromParent()
                }
            }
        }
    }
    
    //custom functions
    func addDot(){
        dot = SKSpriteNode(imageNamed: "dot")
        dot.size = CGSize(width: 30, height: 30)
        dot.zPosition = 1.0
        dot.zRotation = 3.14/2
        
        let dx = person.position.x - self.frame.width/2
        let dy = person.position.y - self.frame.height/2
        
        let rad = atan2(dy, dx)
        
        if moving_cw == true{
            let tempAngle = CGFloat.random(min: rad+1.0, max:rad+2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 113, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            dot.position = path2.currentPoint
        }else if moving_cw == false{
            let tempAngle = CGFloat.random(min: rad-1.0, max:rad-2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 113, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            dot.position = path2.currentPoint
        }
        self.addChild(dot)
    }
    func addGDot(){
        gdot = SKSpriteNode(imageNamed: "gdot")
        gdot.size = CGSize(width: 30, height: 30)
        gdot.zPosition = 1.0
        gdot.zRotation = 3.14/2
        
        let dx = person.position.x - self.frame.width/2
        let dy = person.position.y - self.frame.height/2
        
        let rad = atan2(dy, dx)
        
        if moving_cw == true{
            let tempAngle = CGFloat.random(min: rad+1.0, max:rad+2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 113, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            gdot.position = path2.currentPoint
        }else if moving_cw == false{
            let tempAngle = CGFloat.random(min: rad-1.0, max:rad-2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 113, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            gdot.position = path2.currentPoint
        }
        self.addChild(gdot)
    }
    func moveClockWise(){
        let dx = person.position.x - self.frame.width/2
        let dy = person.position.y - self.frame.height/2
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: true, speed: CGFloat(speed_lim))
        person.runAction(SKAction.repeatActionForever(follow).reversedAction())
        
    }
    func moveCounterClockWise(){
        let dx = person.position.x - self.frame.width/2
        let dy = person.position.y - self.frame.height/2
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: true, speed: CGFloat(speed_lim))
        person.runAction(SKAction.repeatActionForever(follow))
    }
}
