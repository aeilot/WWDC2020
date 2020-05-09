

import SpriteKit
public class EmojiRun : SKScene {
    private var player = SKSpriteNode()
    private var blockSize: CGSize?
    
    override public func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.backgroundColor = #colorLiteral(red: 0.25882352941176473, green: 0.7568627450980392, blue: 0.9686274509803922, alpha: 1.0)
        blockSize = CGSize(width: size.width * 0.05, height: size.height * 0.05)
        createScene()
    }
    
    public override func update(_ currentTime: TimeInterval) {
        
    }
    
    // My Functions
    func createScene(){
        // Create Environment
        
        // Create Controller
        
        // Others
        createBGM()
        createEnermy()
        createPlayer()
    }
    
    func createPlayer(){
        player.texture = SKTexture(image: )
        player.size = blockSize!
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(player)
    }
    
    func createEnermy(){
        
    }
    
    func createBGM(){
        
    }
}

