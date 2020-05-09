//: # Have Fun and ENJOY :)
// Copyright 2020 Louis Aeilot D
// WWDC 2020 Scholarship
// Story: She is a nurse in the emoji world. She will fight against the Emoji Virus. There are also someone who doesn't obay the rule and goes out. She will let them go home.
// ??? ( ??? ) EASTER EGG
// SpriteKit ( COVID RUN )
// The game generates randomly
import PlaygroundSupport
import SpriteKit
import SwiftUI

// Main View
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

// Live Preview
let view = SKView(frame: .zero)
view.presentScene(setUpGame())
view.showsFPS = true
view.showsNodeCount = true
PlaygroundPage.current.setLiveView(mainView())
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    PlaygroundPage.current.liveView = view
}
PlaygroundPage.current.wantsFullScreenLiveView  = true
