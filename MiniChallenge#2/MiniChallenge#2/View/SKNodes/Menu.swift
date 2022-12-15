//
//  Menu.swift
//  MiniChallenge#2
//
//  Created by Pedro Henrique Dias Hemmel de Oliveira Souza on 23/11/22.
//

import Foundation
import SpriteKit

class Menu: SKNode {
    
    //MARK: - Criando as variáveis principais
   
    var audioStatus: Bool = true
    var startGame: Bool = false
    var endGame: Bool = false
    var restartGame: Bool = false
    
    var testeBg: Int = 1
    
    let backgroundMenu = SKSpriteNode()
    
    let startText = SKLabelNode(fontNamed: "")
    let highScoreText = SKLabelNode(fontNamed: "")
    
    var imageHighScoreText = SKSpriteNode()
    
    
    var maconha: String = "eu"
    
    var infoButton: CustomizedButton? = nil
    
    
    var audioButtonOn: CustomizedButton?
    var audioButtonOff: CustomizedButton?
    
    //MARK: - Inicializador
    init(infoButtonAction: @escaping () -> Void) {
        super.init()
    
        self.infoButton = {
            let button = CustomizedButton(imageName: "exclamation", buttonAction: {
                
                infoButtonAction()
            
            })
            return button
        }()
        
        
        self.audioButtonOn = {
            let buttonOn = CustomizedButton(imageName: "volumeBtOn", buttonAction: {
                AVAudio.sharedInstance().pauseBackgroundMusic()
                self.audioButtonOff!.isHidden = false
                self.audioButtonOn!.isHidden = true
            })
            return buttonOn
        }()
        
        self.audioButtonOff = {
            let buttonOff = CustomizedButton(imageName: "volumeBtOff", buttonAction: {
                AVAudio.sharedInstance().playBackgroundMusic("noite.mp3")
                self.audioButtonOff!.isHidden = true
                self.audioButtonOn!.isHidden = false
            })
            return buttonOff
        }()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
  
    //MARK: - Funções de estruturação da classe
    func menuToStruct(sizeView: CGSize) {
        
        self.zPosition = 4
        
        self.backgroundMenu.color = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        self.backgroundMenu.size = sizeView
        self.backgroundMenu.position = CGPoint(x: sizeView.width / 2, y: sizeView.height / 2)
        self.backgroundMenu.zPosition = 4
        
        self.menuToPlayMusicBackground()
        
        self.menuHighScoreToSetProperties(sizeView: sizeView)
        self.highScoreText.zPosition = 5
        self.imageHighScoreText.zPosition = 5
        self.addChild(self.imageHighScoreText)
        self.addChild(self.highScoreText)
        
        self.menuInfoButtonToSetProperties(sizeView: sizeView)
        self.infoButton!.zPosition = 5
        self.addChild(self.infoButton!)

        self.menuAudioButtonToSetProperties(sizeView: sizeView)
        self.audioButtonOn!.zPosition = 5
        self.addChild(self.audioButtonOn!)
        
        self.menuAudioButtonToSetProperties(sizeView: sizeView)
        self.audioButtonOff!.zPosition = 5
        self.addChild(self.audioButtonOff!)

        self.menuStartTextToSetProperties(sizeView: sizeView)
        self.startText.zPosition = 5
        self.addChild(self.startText)
    }
    
    func menuToPlayMusicBackground() {
        AVAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.5
        AVAudio.sharedInstance().playBackgroundMusic("noite.mp3")
    }
    
    func menuStartTextToSetProperties(sizeView: CGSize) {
        self.startText.text = "TOQUE NA TELA PARA INICIAR"
        self.startText.fontName = "AvenirNext-Bold"
        self.startText.fontColor = UIColor(displayP3Red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        self.startText.horizontalAlignmentMode = .center
        self.startText.verticalAlignmentMode = .bottom
        self.startText.position = CGPoint(x: sizeView.width / 2, y: sizeView.height / 2)
    }
    
    func menuAudioButtonToSetProperties(sizeView: CGSize) {
        
        audioButtonOff?.isHidden = true
        
        self.audioButtonOn!.position = CGPoint(x: 40, y: sizeView.height - 40)
        self.audioButtonOff!.position = CGPoint(x: 40, y: sizeView.height - 40)
        
        self.audioButtonOn!.setScale(0.6)
        self.audioButtonOff!.setScale(0.6)
    }
    
    func menuInfoButtonToSetProperties(sizeView: CGSize) {
        self.infoButton!.position = CGPoint(x: sizeView.width - 40, y: sizeView.height - 40)
    }
    
    func menuHighScoreToSetProperties(sizeView: CGSize) {
        
        self.imageHighScoreText = SKSpriteNode(imageNamed: "highscore_icon")
        self.imageHighScoreText.setScale(0.4)
        self.imageHighScoreText.position = CGPoint(x: sizeView.width - 70 - self.imageHighScoreText.frame.width, y: sizeView.height - 35)
        
        self.highScoreText.text = ("\(Score.shared.highScore)")
        self.highScoreText.fontName = "AvenirNext-Bold"
        self.highScoreText.fontColor = UIColor(displayP3Red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        self.highScoreText.fontSize = CGFloat(25)
        self.highScoreText.position = CGPoint(x: sizeView.width - 100, y: sizeView.height - 50)
    }
    
    func tapToRestart() {
        self.isHidden = false
        startGame = false
        Score.shared.scoreLabel.isHidden = true
    }
      
    func tapToStart(){
        self.isHidden = true
        startGame = true
        Score.shared.scoreLabel.isHidden = false
    }
    
}
