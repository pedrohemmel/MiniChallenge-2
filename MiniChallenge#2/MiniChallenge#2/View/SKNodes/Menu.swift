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
    public var audioStatus: Bool = true
    public var startGame: Bool = false
    private var endGame: Bool = false
    private var restartGame: Bool = false

    private var testeBg: Int = 1
    
    private let backgroundMenu = SKSpriteNode()
    
    private let startText = SKLabelNode(fontNamed: "")
    public let highScoreText = SKLabelNode(fontNamed: "")
 
    private let coinText = SKLabelNode(fontNamed: "")
    private var imageCoinText = SKSpriteNode()
   
    private var imageHighScoreText = SKSpriteNode()

    private var infoButton: CustomizedButton? = nil
    private var storeButton: CustomizedButton? = nil

    private var audioButtonOn: CustomizedButton?
    private var audioButtonOff: CustomizedButton?
    
    //MARK: - Inicializador
    init(infoButtonAction: @escaping () -> Void, storeButtonAction: @escaping () -> Void) {
        super.init()
    
        //Criando os botões de configuração do menu
        self.menuToCreateButtonInfo(infoButtonAction: infoButtonAction)
        self.menuToCreateButtonStore(storeButtonAction: storeButtonAction)
        self.menuToCreateButtonOn()
        self.menuToCreateButtonOff()
        
        //Setando icone de som mutado escondido na tela por padrão
        audioButtonOff?.isHidden = true
        
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
        
        self.menuCoinToSetProperties(sizeView: sizeView)
        self.coinText.zPosition = 5
        self.imageCoinText.zPosition = 5
        self.addChild(self.coinText)
        self.addChild(self.imageCoinText)
        
        self.menuHighScoreToSetProperties(sizeView: sizeView)
        self.highScoreText.zPosition = 5
        self.imageHighScoreText.zPosition = 5
        self.addChild(self.imageHighScoreText)
        self.addChild(self.highScoreText)
        
        self.menuAudioButtonToSetProperties(sizeView: sizeView)
        self.audioButtonOn!.zPosition = 5
        self.addChild(self.audioButtonOn!)
        
        self.menuAudioButtonToSetProperties(sizeView: sizeView)
        self.audioButtonOff!.zPosition = 5
        self.addChild(self.audioButtonOff!)
        
        self.menuInfoButtonToSetProperties(sizeView: sizeView)
        self.addChild(self.infoButton!)
        
        self.menuStoreButtonToSetProperties(sizeView: sizeView)
        self.addChild(self.storeButton!)

        self.menuStartTextToSetProperties(sizeView: sizeView)
        self.startText.zPosition = 5
        self.addChild(self.startText)
    }
    
    //Criação do botão de informações
    func menuToCreateButtonInfo(infoButtonAction: @escaping () -> Void) -> Void {
        self.infoButton = {
            let button = CustomizedButton(imageName: "exclamation", lblText: nil, buttonAction: {
                infoButtonAction()
            })
            return button
        }()
    }
    
    //Botão que direciona para a loja de personagens
    func menuToCreateButtonStore(storeButtonAction: @escaping () -> Void) -> Void {
        self.storeButton = {
            let button = CustomizedButton(imageName: "cart.black", lblText: nil, buttonAction: {
                storeButtonAction()
            })
            return button
        }()
    }
    
    //Criação do botão de som ativo
    func menuToCreateButtonOn() {
        self.audioButtonOn = {
            let buttonOn = CustomizedButton(imageName: "volumeBtOn", lblText: nil, buttonAction: {
                AVAudio.sharedInstance().pauseBackgroundMusic()
                self.audioStatus = false
                self.audioButtonOff!.isHidden = false
                self.audioButtonOn!.isHidden = true
            })
            return buttonOn
        }()
    }
    
    //Criação do botão de som desativado
    func menuToCreateButtonOff() {
        self.audioButtonOff = {
            let buttonOff = CustomizedButton(imageName: "volumeBtOff", lblText: nil, buttonAction: {
                AVAudio.sharedInstance().playBackgroundMusic("noite.mp3")
                self.audioStatus = true
                self.audioButtonOff!.isHidden = true
                self.audioButtonOn!.isHidden = false
            })
            return buttonOff
        }()
    }
    
    func menuToPlayMusicBackground() {
        AVAudio.sharedInstance().backgroundMusicPlayer?.volume = 0.5
        AVAudio.sharedInstance().playBackgroundMusic("noite.mp3")
    }
    
    func menuStartTextToSetProperties(sizeView: CGSize) {
        self.startText.text = "TOQUE NA TELA PARA INICIAR".localizedLanguage()
        self.startText.fontName = "AvenirNext-Bold"
//        self.startText.fontColor = UIColor(displayP3Red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        self.startText.fontColor = .black
        self.startText.horizontalAlignmentMode = .center
        self.startText.verticalAlignmentMode = .bottom
        self.startText.position = CGPoint(x: sizeView.width / 2, y: sizeView.height / 2)
    }
    
    func menuAudioButtonToSetProperties(sizeView: CGSize) {
        
        self.audioButtonOn!.position = CGPoint(x: 40, y: sizeView.height - 40)
        self.audioButtonOff!.position = CGPoint(x: 40, y: sizeView.height - 40)
        
        self.audioButtonOn!.buttonView.setScale(0.25)
        self.audioButtonOff!.buttonView.setScale(0.25)
    }
    
    func menuInfoButtonToSetProperties(sizeView: CGSize) {
        self.infoButton!.position = CGPoint(x: sizeView.width - 40, y: sizeView.height - 40)
        self.infoButton?.buttonView.setScale(0.25)
        self.infoButton!.zPosition = 5
    }
    
    func menuStoreButtonToSetProperties(sizeView: CGSize) -> Void {
        self.storeButton?.position = CGPoint(x: 100 + self.audioButtonOn!.frame.width, y: sizeView.height - 40)
        self.storeButton?.setScale(0.3)
        self.storeButton?.zPosition = 5
    }
    
    func menuCoinToSetProperties(sizeView:CGSize) {
        self.coinText.text = ("\(SavePrize.shared.saveCoin)") //inserir o userDefaults do coin
        self.coinText.fontName = "AvenirNext-Bold"
        self.coinText.fontColor = .black
        self.coinText.fontSize = CGFloat(25)
        self.coinText.position = CGPoint(x: sizeView.width - 280, y: sizeView.height - 50)
        
        self.imageCoinText = SKSpriteNode(imageNamed: "moedaCContraste")
        self.imageCoinText.setScale(0.07)
        self.imageCoinText.position = CGPoint(x: sizeView.width - 340, y: sizeView.height - 38)
    }
    func menuToUpdateCountOfCoin() {
        self.coinText.text = ("\(SavePrize.shared.saveCoin)")
    }
    
    func menuHighScoreToSetProperties(sizeView: CGSize) {
        
        self.imageHighScoreText = SKSpriteNode(imageNamed: "highscore_icon")
        self.imageHighScoreText.setScale(0.4)
        self.imageHighScoreText.position = CGPoint(x: sizeView.width - 180 , y: sizeView.height - 35)
        
        self.highScoreText.text = ("\(Score.shared.highScore)")
        self.highScoreText.fontName = "AvenirNext-Bold"
        self.highScoreText.fontColor = .black
        self.highScoreText.fontSize = CGFloat(25)
        self.highScoreText.position = CGPoint(x: sizeView.width - 120, y: sizeView.height - 50)
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
