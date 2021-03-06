//: # WWDC 2020 Student Challenge Project
//: **Saying thank you to all medical workers! **
//: This game simulates how they work in a special way.
//: It is my first Game Project. Apple really let everyone have the chance to code!
//: # It might be the worst game in the world, but it is real. I specially make it like this to let everyone know HOW GREAT THEY ARE !
//: ## Story
//: Miss Moji is a nurse in the emoji world. She is fighting fight against the virus! There will also be someone who doesn't obay the rule and goes out. You are going to help her let them go home.
//: * ??? - EASTER EGG
//: * SpriteKit - Game
//: * SwiftUI - Text
//: ## Notice
//:  * Switch another scene needs one second because they need to change their protective suits.
//:  * Because the protective suit is very heavy, to simulate this, you cannot move continuously.
//:  * Because their work is all the same all day ==> boring, to simulate this, there's no BGM.
//:  * The game may contain impossible cases because this also happens in the real world.
//:  * The game generates randomly because they never know what difficulties they will face.
//:  * Use masks to protect yourself but never use too many
//:  * Go to where those people are and stop them
//:  * DO NOT TOUCH THE VIRUS
//: ## Game Rule
//: * Save people on the streets using limited masks.
//: * Scroe: Mask left, Time, People.
//: * Time Limit:  2 minutes and 50 seconds ( Do not ask me why )
//: * Mask Limit: Random
//: ## About
//: Icons: SF Symbols
//: Images: Emoji
// Copyright 2020 Louis Aeilot D
import PlaygroundSupport
import SpriteKit
import SwiftUI

public enum Environment {
    case dessert
    case normal
    case grass
    case wonderland
}

func getColor(by environment: Environment) -> SKColor{
    switch environment {
    case .dessert:
        return .yellow
    case .normal:
        return .white
    case .grass:
        return .green
    case .wonderland:
        return .magenta
    }
}

func getRandColor() -> SKColor{
    let randEnvir = arc4random_uniform(4)
    var currentEnvir: Environment = .normal
    switch(randEnvir){
    case 1:
        currentEnvir = .dessert
        break
    case 2:
        currentEnvir = .grass
        break
    case 3:
        currentEnvir = .normal
        break
    case 4:
        currentEnvir = .wonderland
        break
    default:
        break
    }
    return getColor(by: currentEnvir)
}

public class EmojiRun : SKScene, SKPhysicsContactDelegate {
    private var player = SKSpriteNode(texture: SKTexture(imageNamed: "nurse.png"))
    private var blockSize: CGSize = CGSize()
    private var currentHeight: Int = 0
    private var currentBrickTrans: Int = 0
    private let brickCount = 20
    private var wearMask = false
    private var currentEnvironment: Environment = .normal
    private let playerCategory: UInt32 = 0x1 << 0
    private let brickCategory: UInt32 = 0x1 << 1
    private let enermyCategory: UInt32 = 0x1 << 2
    private let peopleCategory: UInt32 = 0x1 << 3
    private let backgroundCategory: UInt32 = 0x1 << 4
    private let scoreLabel = SKLabelNode()
    private let timeLabel = SKLabelNode()
    private var timeMinus = 1
    private var currentYFar = Array<Int>()
    private var score = 0 {
        didSet{
            scoreLabel.text = "\(score)   😄 \(people)   😷 \(mask)"
        }
    }
    private var time = 175 {
        didSet{
            timeLabel.text = "🕙 \(time)"
        }
    }
    private var mask = 10 {
        didSet{
            score-=10-mask
            scoreLabel.text = "\(score)   😄 \(people)   😷 \(mask)"
        }
    }
    private var people = 0 {
        didSet{
            score+=people
            scoreLabel.text = "\(score)   😄 \(people)   😷 \(mask)"
        }
    }
    private var currentEnermy = 0
    private var currentPeople = 0
    private var currentBlock = 0
    private var isCreate = false
    
    override public func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.size = view.bounds.size
        blockSize = CGSize(width: size.width * 0.05, height: size.height * 0.05)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.categoryBitMask = backgroundCategory
        self.physicsBody?.contactTestBitMask = playerCategory
        createScene()
        shuffle()
        createPlayer()
        let queue = DispatchQueue.global()
        queue.async {
            while self.time>=0{
                sleep(1)
                self.time -= 1
            }
            self.gameOver()
        }
        let queue2 = DispatchQueue.global()
        queue2.async {
            while self.isCreate == true && self.time>=0{
                for i in 0...self.currentEnermy{
                    var lft = true
                    let curEner = self.childNode(withName: "vir\(i)")
                    let tmp = CGPoint(x: (curEner?.position.x)! - self.blockSize.height, y: (curEner?.position.y)! - self.blockSize.width)
                    if let sp = self.atPoint(tmp) as? SKSpriteNode{
                        if sp.name!.count >= 6 && sp.name!.prefix(5) == "block"{
                            lft = false
                        }
                    }
                    if lft{
                        curEner?.run(SKAction.moveTo(x: (curEner?.position.x)!-(self.blockSize.width)*0.5, duration: 1))
                    }else{
                        curEner?.run(SKAction.moveTo(x: (curEner?.position.x)!+(self.blockSize.width)*0.5, duration: 1))
                    }
                }
                for i in 0...self.currentPeople{
                    var lft = true
                    let curEner = self.childNode(withName: "peo\(i)")
                    let tmp = CGPoint(x: (curEner?.position.x)! - self.blockSize.height, y: (curEner?.position.y)! - self.blockSize.width)
                    if let sp = self.atPoint(tmp) as? SKSpriteNode{
                        if sp.name!.count >= 6 && sp.name!.prefix(5) == "block"{
                            lft = false
                        }
                    }
                    if lft{
                        curEner?.run(SKAction.moveTo(x: (curEner?.position.x)!-(self.blockSize.width)*0.5, duration: 1))
                    }else{
                        curEner?.run(SKAction.moveTo(x: (curEner?.position.x)!+(self.blockSize.width)*0.5, duration: 1))
                    }
                }
            }
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let bodyA : SKPhysicsBody
        let bodyB : SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        }else{
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        if (bodyA.categoryBitMask  == playerCategory && bodyB.categoryBitMask == enermyCategory){
            if !wearMask{
                time -= timeMinus*10
                timeMinus *= 2
            }else{
                wearMask.toggle()
            }
        }
        if (bodyA.categoryBitMask  == playerCategory && bodyB.categoryBitMask == peopleCategory){
            people+=1
            bodyB.node?.removeFromParent()
        } else if (bodyA.categoryBitMask  == peopleCategory && bodyB.categoryBitMask == playerCategory){
            people+=1
            bodyA.node?.removeFromParent()
        }
        if (bodyA.categoryBitMask  == playerCategory && bodyB.categoryBitMask == backgroundCategory){
            currentBrickTrans = 0
            cleanUp()
            shuffle()
        } else if (bodyA.categoryBitMask  == peopleCategory && bodyB.categoryBitMask == backgroundCategory){
            currentBrickTrans = 0
            cleanUp()
            shuffle()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in (touches) {
            let location = touch.location(in: self)
            if let sp = atPoint(location) as? SKSpriteNode{
                if sp.name == "up" {
                    player.run(SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.1))
                } else if sp.name == "rht" {
                    player.run(SKAction.moveTo(x: player.position.x+blockSize.width/2, duration: 0.1))
                } else if sp.name == "lft" {
                    player.run(SKAction.moveTo(x: player.position.x - blockSize.width/2, duration: 0.1))
                } else if sp.name == "mask" {
                    if !wearMask{
                        mask -= 1
                        wearMask.toggle()
                    }
                }
            }
        }
    }
    
    // My Func
    func createScene(){
        // Create Label
        scoreLabel.zPosition = 20
        timeLabel.zPosition = 20
        scoreLabel.fontSize = 35
        timeLabel.fontSize = 35
        scoreLabel.color = .white
        timeLabel.color = .white
        timeLabel.verticalAlignmentMode = .top
        timeLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height-40)
        timeLabel.position = CGPoint(x: self.size.width/2, y: self.size.height)
        scoreLabel.text = "\(score)   😄 \(people)   😷 \(mask)"
        timeLabel.text = "🕙 \(time)"
        self.addChild(timeLabel)
        self.addChild(scoreLabel)
        // Create Environment
        self.backgroundColor = #colorLiteral(red: 0.25882352941176473, green: 0.7568627450980392, blue: 0.9686274509803922, alpha: 1.0)
        self.zPosition = -1
        // Create Floor
        let ground = SKSpriteNode(color: getColor(by: currentEnvironment), size: CGSize(width: self.size.width, height: blockSize.height))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = CGPoint(x: 0, y: 0)
        ground.texture = SKTexture()
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.size.width, height: blockSize.height))
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.categoryBitMask = brickCategory
        ground.physicsBody?.isDynamic = false
        self.addChild(ground)
        // Create Controller
        let controlSize = CGSize(width: blockSize.width, height: blockSize.width)
        let up = SKSpriteNode(texture: SKTexture(image: UIImage(systemName: "arrow.up.circle")!), size: controlSize)
        up.name = "up"
        up.alpha = 0.6
        up.anchorPoint = CGPoint(x: 0, y: 0)
        let rht = SKSpriteNode(texture: SKTexture(image: UIImage(systemName: "arrow.right.circle")!), size: controlSize)
        rht.alpha = 0.6
        rht.name = "rht"
        rht.anchorPoint = CGPoint(x: 0, y: 0)
        let lft = SKSpriteNode(texture: SKTexture(image: UIImage(systemName: "arrow.left.circle")!), size: controlSize)
        lft.alpha = 0.6
        lft.name = "lft"
        lft.anchorPoint = CGPoint(x: 0, y: 0)
        let mask = SKSpriteNode(texture: SKTexture(image: UIImage(systemName: "square.fill")!), size: controlSize)
        mask.name = "mask"
        mask.alpha = 0.6
        mask.anchorPoint = CGPoint(x: 0, y: 0)
        // Set Pos
        let trans: CGFloat = controlSize.width*0.5
        lft.position = CGPoint(x: trans, y: trans)
        rht.position = CGPoint(x: trans+controlSize.width*2, y: trans)
        up.position = CGPoint(x: trans+controlSize.width, y: trans+controlSize.height)
        mask.position = CGPoint(x: self.size.width - controlSize.width - trans, y: trans)
        lft.zPosition = 20
        rht.zPosition = 20
        up.zPosition = 20
        mask.zPosition = 20
        self.addChild(lft)
        self.addChild(rht)
        self.addChild(up)
        self.addChild(mask)
    }
    
    func shuffle(){
        let randEnvir = arc4random_uniform(4)
        var currentEnvir: Environment = .normal
        switch(randEnvir){
        case 0:
            currentEnvir = .dessert
            break
        case 1:
            currentEnvir = .grass
            break
        case 2:
            currentEnvir = .normal
            break
        case 3:
            currentEnvir = .wonderland
            break
        default:
            break
        }
        currentEnvironment = currentEnvir
        createGround()
    }
    
    func createGround(){
        var randVal = arc4random_uniform(10)
        if(randVal <= 3){
            randVal += 4
        }
        currentYFar = Array(repeating: 0, count: Int(randVal))
        for _ in 1...randVal{
            let color = getRandColor()
            let randHeight = arc4random_uniform(UInt32(currentHeight))
            let randWidth = arc4random_uniform(UInt32(brickCount - currentBrickTrans))
            let randY = arc4random_uniform(3)
            let block = SKSpriteNode(color: color, size: CGSize(width: CGFloat(randWidth) * blockSize.width, height: blockSize.height))
            block.anchorPoint = CGPoint(x: 0, y: 0)
            let posY: CGFloat = CGFloat(randHeight+1) * (blockSize.width + blockSize.height)
            let posX: CGFloat = CGFloat(currentBrickTrans + currentYFar[Int(randHeight)] + Int(randY+1)) * blockSize.width
            block.position = CGPoint(x: posX, y: posY)
            block.texture = SKTexture()
            block.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: posX, y: posY, width: CGFloat(randWidth) * blockSize.width, height: blockSize.height))
            block.physicsBody?.allowsRotation = false
            block.physicsBody?.categoryBitMask = brickCategory
            block.name = "block\(currentBlock)"
            currentBlock += 1
            self.addChild(block)
            if randHeight+1 >= currentHeight {
                currentHeight += 1
            }
            if currentYFar[currentHeight-1] == Int(posY - CGFloat(currentBrickTrans) * blockSize.width) {
                currentYFar[currentHeight-1] = Int(randY+randWidth)
            }
            if randWidth > 3{
                let randVir = arc4random_uniform(2)
                switch(randVir){
                case 0:
                    let randVir = arc4random_uniform(3)
                    for _ in 0...randVir {
                        let vir = SKSpriteNode(texture: SKTexture(imageNamed: "virus.png"))
                        vir.size = CGSize(width: blockSize.width - 1, height: blockSize.width - 1)
                        vir.anchorPoint = CGPoint(x: 0, y: 0)
                        vir.position = CGPoint(x: posX + blockSize.height * 2, y: posY + blockSize.height)
                        vir.physicsBody = SKPhysicsBody(texture: vir.texture!, size: vir.size)
                        vir.physicsBody?.allowsRotation = false
                        vir.physicsBody?.categoryBitMask = enermyCategory
                        vir.physicsBody?.affectedByGravity = true
                        vir.name = "vir\(currentEnermy)"
                        vir.physicsBody?.contactTestBitMask = playerCategory |  peopleCategory | backgroundCategory
                        currentEnermy += 1
                        self.addChild(vir)
                    }
                    break
                default:
                    let peo = SKSpriteNode(texture: SKTexture(imageNamed: "health_person.png"))
                    peo.size = CGSize(width: blockSize.width - 1, height: blockSize.width - 1)
                    peo.anchorPoint = CGPoint(x: 0, y: 0)
                    peo.position = CGPoint(x: posX, y: posY + blockSize.height)
                    peo.physicsBody = SKPhysicsBody(texture: peo.texture!, size: peo.size)
                    peo.physicsBody?.allowsRotation = false
                    peo.physicsBody?.categoryBitMask = peopleCategory
                    peo.physicsBody?.contactTestBitMask = playerCategory |  enermyCategory | backgroundCategory
                    peo.physicsBody?.affectedByGravity = true
                    peo.name = "peo\(currentPeople)"
                    currentPeople += 1
                    self.addChild(peo)
                    break
                }
            }
        }
        isCreate = true
    }
    
    func createPlayer(){
        player.size = CGSize(width: blockSize.width - 1, height: blockSize.width - 1)
        player.anchorPoint = CGPoint(x: 0, y: 0)
        player.position = CGPoint(x: blockSize.width * 2, y: blockSize.height)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enermyCategory |  peopleCategory | backgroundCategory
        self.addChild(player)
    }
    
    func gameOver(){
        time = 0
        cleanUp()
        let label = SKLabelNode()
        label.zPosition = 20
        label.fontSize = 35
        label.color = .white
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: self.size.width/2, y: self.size.width/2)
        label.text = "Your Score: \(score)   Say Thank You to Medical workers!"
        self.addChild(label)
    }
    
    func cleanUp(){
        currentHeight = 0
        currentBrickTrans = 0
        currentYFar.removeAll()
        for i in 0...currentBlock{
            let tmp = self.childNode(withName: "block\(i)")
            tmp?.removeFromParent()
        }
        for i in 0...currentPeople{
            let tmp = self.childNode(withName: "peo\(i)")
            tmp?.removeFromParent()
        }
        for i in 0...currentEnermy{
            let tmp = self.childNode(withName: "vir\(i)")
            tmp?.removeFromParent()
        }
        isCreate = false
    }
}

struct mainView: View{
    var body: some View{
        VStack{
            Text("Swift Student Challenge")
                .font(.title)
                .bold()
            Text("A Game which simulates Medical Workers Work in a special way")
                .font(.subheadline)
                .foregroundColor(Color.gray)
            Text("Read the DOC first")
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
    }
}

func setUpGame() -> SKScene {
    let scene = EmojiRun()
    scene.scaleMode = .aspectFill
    return scene
}

let bounds = UIScreen.main.bounds
let view = SKView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
view.presentScene(setUpGame())
view.showsFPS = true
view.showsNodeCount = true
PlaygroundPage.current.setLiveView(mainView())
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    PlaygroundPage.current.liveView = view
}
