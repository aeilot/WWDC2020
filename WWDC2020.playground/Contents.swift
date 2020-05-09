//: # WWDC 2020 Student Challenge Project
//: ## Story
//: Miss Moji is a nurse in the emoji world. She is fighting fight against the virus! There will also be someone who doesn't obay the rule and goes out. You are going to help her let them go home.
//: * ??? - EASTER EGG
//: * SpriteKit - Game
//: * SwiftUI - Text
//: ## Notice
//:  * The game generates randomly
//:  * Use masks to protect yourself but never use too many
//:  * Go to where those people are and stop them
//:  * DO NOT TOUCH THE VIRUS
//: ## Game Rule
//: * Save people on the streets using limited masks.
//: * Scroe: Mask left, Time, People.
//: * Time Limit:  2 minutes and 50 seconds ( Do not ask me why )
//: * Mask Limit: Random
// Copyright 2020 Louis Aeilot D
import PlaygroundSupport
import SpriteKit
import SwiftUI

struct mainView: View{
    var body: some View{
            VStack{
                Text("Swift Student Challenge")
                    .font(.title)
                    .bold()
                Text("A Game about virus and medical workers in the emoji world")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                Text("Say thank you to Medical Workers")
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


let view = SKView(frame: .zero)
view.presentScene(setUpGame())
view.showsFPS = true
view.showsNodeCount = true
PlaygroundPage.current.setLiveView(mainView())
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    PlaygroundPage.current.liveView = view
}
