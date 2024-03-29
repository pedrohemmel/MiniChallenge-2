//
//  GameScene.swift
//  MiniChallenge#2
//
//  Created by Pedro Henrique Dias Hemmel de Oliveira Souza on 16/11/22.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Global Variables
    private var prize = AnimatedObject("moeda")
    private var prizeIsRemoved = false
    private var prizeGame = 0
    private var prizeLblGame = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var prizeImgGame = SKSpriteNode(imageNamed: "moedaCContraste")
    
    private var menu: Menu? = nil
    private var pausedGameScreen: PausedGame? = nil
    private var gameOverScreen: GameOver? = nil
    
    private let character = Character.character
    private let bulk = AnimatedObject("vulto")
    private var bulkAppeared = false
    
    private var gameStarted = false
    private var gameOver = false
    private var pausedGame = false
    private var givedUpGame = false
    
    private var colisionAllowed = true
    private var colisionCoinAllowed = true
    
    private var timeToWaitForMusic: Date = .now
    private var timeMusicPlayed = false
    
    //Sprites do ambiente de jogo
    private var pausedButton: CustomizedButton? = nil
    private var ground: SKSpriteNode = SKSpriteNode()
    private var ceiling = SKSpriteNode()
    
    private var day = true
    private var transitionDay = false
    private var startedTransitionDay = false
    
    private var night = false
    private var transitionNight = false
    private var startedTransitionNight = false
    
    private var backgroundDia1 = SKSpriteNode()
    private var backgroundDia2 = SKSpriteNode()
    private var backgroundChoosedToTransition: SKSpriteNode? = nil
    
    private var timeStartedPause: Date? = nil
    private var timeEndedPause: Date? = nil
    private var timeOfChangingBackground: Date = .now
    
    let gameSKNode = SKNode()
    let animationOfBackground = SKNode()
    
    let moveAction = SKAction.moveTo(x: -100, duration: 3)
    let removeAction = SKAction.removeFromParent()
    
    //Variável utilizada para auxiliar na lógica de movimento dos objetos
    private var movedActionOfObstacles = SKAction()
    private var obstaclesInAction = SKNode()
    
    override func didMove(to view: SKView) {
       
        //Relacionando o SKPhysicsContactDelegate à classe self
        self.physicsWorld.contactDelegate = self

        //Menu
        self.menu = Menu(infoButtonAction: {
            let infoScreen = Info(size: self.frame.size)
            infoScreen.scaleMode = .aspectFill
            
            //removendo pai do HighScore pois se não, quando voltar para essa tela, vai dar erro ao tentar adicionar um pai no HighScore ja que ele ja teria um
            Score.shared.scoreLabel.removeFromParent()
            //Removendo também das vidas do personagem
            self.character.characterToRemoveLifesFromParent()
            
            self.view?.presentScene(infoScreen, transition: SKTransition.fade(with: .black, duration: 1))
        }, storeButtonAction: {
            let storeScreen = StoreCharacterScene(size: self.frame.size)
            
            storeScreen.scaleMode = .aspectFill
            
            //removendo pai do HighScore pois se não, quando voltar para essa tela, vai dar erro ao tentar adicionar um pai no HighScore ja que ele ja teria um
            Score.shared.scoreLabel.removeFromParent()
            //Removendo também das vidas do personagem
            self.character.characterToRemoveLifesFromParent()
            
            self.view!.presentScene(storeScreen, transition: SKTransition.fade(with: .black, duration: 1))
        })
        
        //Chamando a função que estrutura o menu principal
        self.menu!.menuToStruct(sizeView: self.size)
        
        //Pause do jogo
        pauseButtonToCreate()
        self.pausedGameScreen = PausedGame(view: self)
        self.buttonsOfPausedScreenToCreate()
        
        //Score
        Score.shared.scoreLabel.fontSize = 25
        Score.shared.scoreLabel.fontColor = .red
        Score.shared.scoreLabel.position = CGPoint(x: self.frame.width - 90, y: self.frame.height - 48)
        Score.shared.scoreLabel.zPosition = 2
        
        //Game over
        self.gameOverScreen = GameOver(view: self)
        self.gameOverScreen?.creatingRestartButton(view: self, actionOfBtnRestart: {
            self.givedUpGame = true
    
            self.obstaclesInAction.removeAllChildren()
            self.movedActionOfObstacles = SKAction.removeFromParent()
            self.obstaclesInAction.removeAllActions()
            self.removeAllActions()
            
            self.mostraMenu()
        })
        
        //Moeda
        self.structuringPrizeLbl()
        self.structuringPrizeImg()
        
        //Background
        self.creatingAnimatedBackground()
        
        //Chão do jogo
        self.ground = groundToCreate(ground: SKSpriteNode(imageNamed: "chao"))
        self.ground.zPosition = 2
        
        //Teto do jogo
        self.ceiling = self.ceilingToCreate(ceiling: self.ceiling)
        
        
        //Criando e chamando as funções que fazem a estrutura do personagem
        self.character.characterView = AnimatedObject("personagem_alma")
        self.character.characterView = character.characterToApplyProperties(character: character.characterView, view: self)
        self.character.characterView = character.characterToCollide(character: character.characterView)
        self.character.characterLife = character.characterLifeToSetProperties(characterLife: self.character.characterLife, view: self)
        
        //Vulto atrás do personagem
        self.bulk.setScale(0.22)
        self.bulk.zPosition = 3
        if night {
            self.bulk.position = CGPoint(x: 10, y: self.frame.height / 3)
        } else {
            self.bulk.position = CGPoint(x: -190, y: self.frame.height / 3)
        }
        
        //Escondendo imagens do jogo antes de começar
        self.hideLifeScoreAndPauseButton()
        
        //Adicionando os filhos para a gameSKNode
        self.gameSKNode.addChild(Score.shared.scoreLabel)
        self.gameSKNode.addChild(self.prizeLblGame)
        self.gameSKNode.addChild(self.prizeImgGame)
        self.gameSKNode.addChild(self.character.characterView)
        self.gameSKNode.addChild(self.bulk)
        self.gameSKNode.addChild(self.ceiling)
        self.gameSKNode.addChild(self.ground)
        self.gameSKNode.addChild(self.animationOfBackground)
        self.gameSKNode.addChild(self.pausedButton!)
        for life in self.character.characterLife {
            self.gameSKNode.addChild(life)
        }
        
        //Adicionando a SKNode do jogo na cena
        self.addChild(self.menu!)
        self.addChild(self.gameSKNode)
        self.addChild(self.pausedGameScreen!)
        self.addChild(self.gameOverScreen!)
    }
    
    //Vulto atrás do personagem
    func monsterAppear() {

        if !self.bulkAppeared {
            if self.day {
                if self.transitionDay {
                    self.bulk.run(SKAction.moveBy(x: 200, y: 0, duration: 25))
                    self.bulkAppeared = true
                }
            }
        } else {
            if self.night {
                if self.transitionNight {
                    self.bulk.run(SKAction.moveBy(x: -200, y: 0, duration: 25))
                    self.bulkAppeared = false
                }
            }
        }
        
        
    }
    
    //MARK: - Criando objetos da cena principal
    
    func deleteActionsAndObstacles() {
        self.movedActionOfObstacles = SKAction.removeFromParent()
        self.removeAllActions()
    }
    
    func restartLifeAndScore() -> Void {
        Score.shared.gameScore = 0

        for life in self.character.characterLife {
            life.removeFromParent()
        }
        
        self.character.characterLife.removeAll()
        self.character.characterLife = [SKSpriteNode(imageNamed: "caveira_vermelha"), SKSpriteNode(imageNamed: "caveira_vermelha"), SKSpriteNode(imageNamed: "caveira_vermelha")]
        self.character.characterLife = self.character.characterLifeToSetProperties(characterLife: self.character.characterLife, view: self)
        for life in self.character.characterLife {
            self.gameSKNode.addChild(life)
        }

    }
    
    func hideLifeScoreAndPauseButton() -> Void {
        Score.shared.scoreLabel.isHidden = true
        
        //Escondendo score de moedas antes de começar o jogo
        self.prizeLblGame.isHidden = true
        self.prizeImgGame.isHidden = true
        
        for life in self.character.characterLife {
            life.isHidden = true
        }
        
        self.pausedButton?.isHidden = true
    }
    
    func appearLifeScoreAndPauseButton() -> Void {
        Score.shared.scoreLabel.isHidden = false
        
        //Mostrando score de moedas depois de começar o jogo
        self.prizeLblGame.isHidden = false
        self.prizeImgGame.isHidden = false
        
        for life in self.character.characterLife {
            life.isHidden = false
        }
        
        self.pausedButton?.isHidden = false
    }
    
    func pauseButtonToCreate() -> Void {
        self.pausedButton = CustomizedButton(imageName: "pause.fill", lblText: nil, buttonAction: {
            if !self.pausedGame {
                self.pausedGame = true
                self.pauseGameSKNode()
                self.pausedGameScreen!.isHidden = false
                
                //setando tempo de agora para está variável para auxiliar na soma do tempo de pause para a variável de mudança de backgrounds
                self.timeStartedPause = .now
                self.stopingBackgroundAnimation()
            }
            
        })
        self.pausedButton?.setScale(0.5)
        self.pausedButton?.zPosition = 2
        self.pausedButton?.position = CGPoint(x: self.frame.width - 40, y: self.frame.height - 39)
    }
    
    func pauseGameSKNode() -> Void {
        self.gameSKNode.isPaused = true
        
        self.character.characterView.physicsBody?.affectedByGravity = false
        self.character.characterView.physicsBody?.isDynamic = false
    }
    
    func continueGameSKNode() -> Void {
        self.gameSKNode.isPaused = false
        
        self.character.characterView.physicsBody?.affectedByGravity = true
        self.character.characterView.physicsBody?.isDynamic = true
    }
    
    func ceilingToCreate(ceiling: SKSpriteNode) -> SKSpriteNode {
        
        ceiling.size = CGSize(width: self.frame.width, height: 1)
        ceiling.position = CGPoint(x: self.frame.width / 2, y: self.frame.height)
        ceiling.zPosition = 0
        
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ceiling
        ceiling.physicsBody?.collisionBitMask = PhysicsCategory.character
        ceiling.physicsBody?.affectedByGravity = false
        ceiling.physicsBody?.isDynamic = false
        
        return ceiling
    }
    
    //Setando propriedades da labe da moeda
    func structuringPrizeLbl() -> Void {
        self.prizeLblGame.position = CGPoint(x: self.size.width - 160, y: self.size.height - 48)
        self.prizeLblGame.fontSize = 25
        self.prizeLblGame.zPosition = 2
    }
    
    func structuringPrizeImg() -> Void {
        self.prizeImgGame.position = CGPoint(x: self.size.width - 210 - self.prizeLblGame.frame.width, y: self.size.height - 37)
        self.prizeImgGame.setScale(0.065)
        self.prizeImgGame.zPosition = 2
    }
    
    func groundToCreate(ground: SKSpriteNode) -> SKSpriteNode {
        ground.size = CGSize(width: self.frame.width, height: 60)
        ground.position = CGPoint(x: self.frame.width / 2, y: 30)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.character | PhysicsCategory.obstacle
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.character | PhysicsCategory.obstacle
        
        return ground
    }
    
    func buttonsOfPausedScreenToCreate() {
        self.pausedGameScreen!.creatingAllButtons(
            view: self,
            actionOfBtnGiveUp: {
                self.givedUpGame = true
        
                self.obstaclesInAction.removeAllChildren()
                self.obstaclesInAction.removeAllActions()
                self.deleteActionsAndObstacles()
                
                //apagando moeda para reiniciar moeda
                self.prize.removeFromParent()
                
                self.mostraMenu()
                
                //Adicionando tempo de diferença do pause para o tempo de mudança dos bakcgrounds
                self.timeEndedPause = .now
                self.timeOfChangingBackground = self.timeOfChangingBackground.addingTimeInterval(self.timeEndedPause!.timeIntervalSinceReferenceDate - self.timeStartedPause!.timeIntervalSinceReferenceDate)
                self.playingBackgroundAnimation()
            },
            actionOfBtnContinue: {
                self.pausedGame = false
                self.continueGameSKNode()
                self.pausedGameScreen!.isHidden = true
                
                //Adicionando tempo de diferença do pause para o tempo de mudança dos bakcgrounds
                self.timeEndedPause = .now
                self.timeOfChangingBackground = self.timeOfChangingBackground.addingTimeInterval(self.timeEndedPause!.timeIntervalSinceReferenceDate - self.timeStartedPause!.timeIntervalSinceReferenceDate)
                self.playingBackgroundAnimation()
            })
    }
    
    func mostraMenu() {
        self.menu!.tapToRestart()
        
        Score.shared.gameScore = 0
        
        self.gameStarted = false
        
        self.continueGameSKNode()
        self.pausedGame = false
        self.pausedGameScreen!.isHidden = true
        
        self.character.characterView.isHidden = false
        
        self.gameOverScreen?.isHidden = true
        
        self.restartLifeAndScore()
        self.hideLifeScoreAndPauseButton()
    }
    
    func playingBackgroundAnimation() {
        self.backgroundDia1.isPaused = false
        self.backgroundDia2.isPaused = false
        
    }
    
    func stopingBackgroundAnimation() {
        self.backgroundDia1.isPaused = true
        self.backgroundDia2.isPaused = true
    }
    
   
    
    //Função utilizada para organizar melhor o código no switch case
    func settingPropertiesObstacle(obstacle: Obstacle, obstacleView: SKSpriteNode) -> SKSpriteNode {
        obstacle.obstacleView = obstacleView
    
        obstacle.obstacleView = obstacle.obstacleToSetSize(obstacle: obstacle.obstacleView)
        obstacle.obstacleView = obstacle.obstacleToSetPhysics(obstacle: obstacle.obstacleView)
        obstacle.obstacleView = obstacle.obstacleToCollide(obstacle: obstacle.obstacleView)
        
        return obstacleView
    }

    //
    func sortObstacle() -> Obstacle {
        let obstacleSorted = self.sorteiaObstaculoMaisProvavel()
        
        //Criando os objetos do tipo do obstaculo sorteado e setando as devidas propriedades
        switch obstacleSorted {
        case 0:
            let birdObstacle = BirdObstacle()
            birdObstacle.obstacleView = AnimatedObject("corvo")
            birdObstacle.obstacleView.setScale(0.15)
            birdObstacle.obstacleView.size = CGSize(width: 80, height: 45)
            birdObstacle.obstacleView = settingPropertiesObstacle(obstacle: birdObstacle, obstacleView: birdObstacle.obstacleView)
            
            let distance = CGFloat(self.frame.width + self.obstaclesInAction.frame.width)
            
            //Setando ação do obstáculo e colocando uma estrutura condicional que, conforme o jogo passa, vai ficando mais rápido e o objeto tem que ajustar mais para baixo, e é isso o que acontece
            if Score.shared.gameScore < 70 {
                birdObstacle.actionObstacle = SKAction.moveBy(x: -distance, y: -CGFloat(Int.random(in: 400...500)), duration: 0.004 * distance)
            } else {
                birdObstacle.actionObstacle = SKAction.moveBy(x: -distance, y: -CGFloat(Int.random(in: 500...600)), duration: 0.004 * distance)
            }
            
            
            birdObstacle.obstacleView.position.y = self.frame.height - CGFloat(Int.random(in: 50...100))
            return birdObstacle
        case 1:
            let tombstoneObstacle = TombstoneObstacle()
            tombstoneObstacle.obstacleView = SKSpriteNode(imageNamed: "lapide1")
            tombstoneObstacle.obstacleView.setScale(0.2)
            tombstoneObstacle.obstacleView.size = CGSize(width: 150, height: 90)
            tombstoneObstacle.obstacleView = settingPropertiesObstacle(obstacle: tombstoneObstacle, obstacleView: tombstoneObstacle.obstacleView)
            
            tombstoneObstacle.obstacleView.position.y = self.ground.frame.height + (tombstoneObstacle.obstacleView.frame.height / 2)
            return tombstoneObstacle
        case 2:
            let ghostObstacle = GhostObstacle()
            ghostObstacle.obstacleView = AnimatedObject("fantasma")
            ghostObstacle.obstacleView.setScale(0.15)
            ghostObstacle.obstacleView.size =  CGSize(width: 80, height: 80)
            ghostObstacle.obstacleView = settingPropertiesObstacle(obstacle: ghostObstacle, obstacleView: ghostObstacle.obstacleView)
            
            if Score.shared.gameScore < 70 {
                let distance = CGFloat(self.frame.width + self.obstaclesInAction.frame.width)
                ghostObstacle.actionObstacle = SKAction.moveBy(x: 0, y: (-self.frame.height / 1.5) + CGFloat(Int.random(in: -300...150)), duration: 0.004 * distance)
            } else {
                let distance = CGFloat(self.frame.width + self.obstaclesInAction.frame.width)
                ghostObstacle.actionObstacle = SKAction.moveBy(x: 0, y: (-self.frame.height / 1.5) + CGFloat(Int.random(in: -400...200)), duration: 0.004 * distance)
            }
            
            ghostObstacle.obstacleView.position.y = self.frame.height
            return ghostObstacle
            
        case 3:
            let spiderObstacle = SpiderObstacle()
            spiderObstacle.obstacleView = SKSpriteNode(imageNamed: "aranha")
            spiderObstacle.obstacleView.size = CGSize(width: 100, height: 140)
            spiderObstacle.obstacleView = settingPropertiesObstacle(obstacle: spiderObstacle, obstacleView: spiderObstacle.obstacleView)
            
            spiderObstacle.obstacleView.position.y = self.size.height - (spiderObstacle.obstacleView.frame.height / 2)
            return spiderObstacle
    
        default:
            //Obstaculo poadrão
            let birdObstacle = BirdObstacle()
            birdObstacle.obstacleView.position.y = self.frame.height * 2
            return birdObstacle
        }
    }
    
    func setPropertiesOfPrize() -> Void {
        self.prize.setScale(0.065)
        
        let randomPrize = Float.random(in: (Float(prize.frame.height / 2) + Float(self.ground.frame.height))...(Float(self.size.height) - Float(prize.frame.height))) //random de Y
        
        self.prize.position = CGPoint(x:self.size.width + 100, y: CGFloat(randomPrize))
        self.prize.zPosition = 2
        
        self.prize.physicsBody = SKPhysicsBody(circleOfRadius: self.prize.size.width / 2)
        self.prize.physicsBody?.affectedByGravity = false
        
        self.prize.physicsBody?.categoryBitMask = PhysicsCategory.prize
        self.prize.physicsBody?.contactTestBitMask = PhysicsCategory.character
        self.prize.physicsBody?.collisionBitMask = PhysicsCategory.character
    }
    
    func createPrizeObject(){ //colocar ela dentro de um random para gerar aleatorio
        
        if gameStarted {
            
            self.prize = AnimatedObject("moeda")
            
            self.setPropertiesOfPrize()
            
            self.prize.run(SKAction.moveBy(x: -self.size.width - 200, y: 0, duration: 5))
            
            self.gameSKNode.addChild(prize)
        }
        
    }
    
    func restartPrize() {
        
        if gameStarted {
            self.prize.removeFromParent()
            self.prize.removeAllActions()
            
            self.prize = AnimatedObject("moeda")
            
            self.setPropertiesOfPrize()
            
            self.prize.run(SKAction.moveBy(x: -self.size.width - 200, y: 0, duration: 5))
            
            self.gameSKNode.addChild(prize)
        }
        
    }
    
    func verifyPrize() {
        if prize.position.x <= -90 && !self.prizeIsRemoved {
            
            self.restartPrize()
        } else {
            if prizeIsRemoved {
                
                self.restartPrize()
                
                self.prizeIsRemoved = false
            }
        }
    }

    //Função que chama a função que gera os obstáculos, seta as propriedades dos mesmos e adiciona na cena
    func generatingNewObstacle() {
        if !givedUpGame && !pausedGame {
            self.obstaclesInAction = SKNode()
            let sortedObstacle = self.sortObstacle()
           
                        
            sortedObstacle.obstacleView.position.x = self.frame.width + (self.frame.width / 4)
                    
            sortedObstacle.obstacleView.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            sortedObstacle.obstacleView.physicsBody?.collisionBitMask = PhysicsCategory.character
            sortedObstacle.obstacleView.physicsBody?.contactTestBitMask = PhysicsCategory.character
            sortedObstacle.obstacleView.physicsBody?.affectedByGravity = false
            sortedObstacle.obstacleView.physicsBody?.isDynamic = false
                    
            sortedObstacle.obstacleView.run(sortedObstacle.actionObstacle)
            self.obstaclesInAction.addChild(sortedObstacle.obstacleView)
            
            self.obstaclesInAction.zPosition = 2
            self.obstaclesInAction.run(self.movedActionOfObstacles)
            self.gameSKNode.addChild(obstaclesInAction)
        }
    }
    
    func creatingMoveOfObstacle(tempo: Double, duration: Double) {
        let spawn = SKAction.run({ () in
            self.generatingNewObstacle()
            
        })
        
        let delay = SKAction.wait(forDuration: tempo)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + self.obstaclesInAction.frame.width)
        let movePipes = SKAction.moveBy(x: -distance - 300, y: 0, duration: duration * distance)
        let removePipes = SKAction.removeFromParent()
        self.movedActionOfObstacles = SKAction.sequence([movePipes, removePipes])
        
    }
    
    //Função que aguarda um tempo determinado para permitir com que o personagem possa colidir com os obstaculos
    func settingTimeOfInvincibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.colisionAllowed = true
        }
    }
    
    //Função que aguarda um tempo determinado para permitir com que o personagem possa colidir com os obstaculos
    func settingTimeOfInvincibilityWithCoin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.colisionCoinAllowed = true
        }
    }
    
    //Função que detecta o contato dos corpos
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
    
        if !givedUpGame {
            
            if firstBody.categoryBitMask == PhysicsCategory.character && secondBody.categoryBitMask == PhysicsCategory.prize || firstBody.categoryBitMask == PhysicsCategory.prize && secondBody.categoryBitMask == PhysicsCategory.character{
                
                
                
                if self.colisionCoinAllowed {
                    
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if menu!.audioStatus {
                        AVAudio.sharedInstance().playSecondarySoundEffect("coinsound.wav")
                    }
                    
                    firstBody.categoryBitMask == PhysicsCategory.prize ? firstBody.node?.removeFromParent() : secondBody.node?.removeFromParent()
                    self.prizeIsRemoved = true
                    
                    self.prizeGame += 1
                    SavePrize.shared.addcCoin()
                    self.menu?.menuToUpdateCountOfCoin()
                    
                    self.colisionCoinAllowed = false
                }
                self.settingTimeOfInvincibilityWithCoin()
                
                
            }
          

            //Estrutura condicional que verifica os corpos de contato
            if firstBody.categoryBitMask == PhysicsCategory.character && secondBody.categoryBitMask == PhysicsCategory.obstacle || firstBody.categoryBitMask == PhysicsCategory.obstacle && secondBody.categoryBitMask == PhysicsCategory.character {
                
//                Decrementando itens da lista de vidas do jogo
                if self.colisionAllowed {

                    if !(self.character.characterLife.count <= 1) {
                        
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                        self.character.characterLife.last?.removeFromParent()
                        self.character.characterLife.removeLast()
                        
                        if menu!.audioStatus {
                            AVAudio.sharedInstance().playSoundEffect("impacto.mp3")
                        }
                    } else {
                        //MARK: - GAME OVER
                        if !gameOver {

                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            
                            if menu!.audioStatus {
                                AVAudio.sharedInstance().playSoundEffect("gameover.mp3")
                            }
                            
                            //apagando moeda
                            self.prize.removeFromParent()
                            
                            self.character.characterLife.last?.removeFromParent()
                            self.character.characterLife.removeLast()
                            self.character.characterView.isHidden = true

                            self.gameOver = true
                            self.pausedGame = true
                            self.gameOverScreen!.isHidden = false
                            
                            self.pauseGameSKNode()
                            self.gameOverScreen?.updatingFinalScore(newFinalScore: Int(Score.shared.gameScore))
                        }
                    }
                    //Deixando a colisao permitida igual a false para o fator invencibilidade do personagem
                    self.colisionAllowed = false
                }
                self.settingTimeOfInvincibility()
                if firstBody.categoryBitMask == PhysicsCategory.obstacle {
                    firstBody.node?.removeFromParent()
                } else {
                    secondBody.node?.removeFromParent()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.gameStarted {
            
            self.timeOfChangingBackground = .now
            
            self.gameStarted = true
            self.givedUpGame = false
            self.gameOver = false
            
            self.createPrizeObject()
            self.prizeGame = 0
            self.prizeLblGame.text = "\(prizeGame)"
            
            self.appearLifeScoreAndPauseButton()
            self.menu!.tapToStart()
            self.creatingMoveOfObstacle(tempo: 2.5, duration: 0.004)
        } else {
            if !self.pausedGame {
                self.character.characterView = self.character.characterToFly(character: self.character.characterView)
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
    }
    
    //MARK: - Algoritmo para sortear o obstaculo mais provável de acertar o jogador
    
    func sorteiaObstaculoMaisProvavel() -> Int {
        if self.character.characterView.position.y <= self.size.height / 2 {
            return Int.random(in: 0...1)
        } else {
            return Int.random(in: 2...3)
        }
    }
    
    //MARK: - FUNÇÕES DE BACKGROUND DO JOGO JUNTAMENTE COM TRANSIÇÃO DE DIA E NOITE
    
    func structuringBackgroundAndApplyingAction(backgroundName: String, action: SKAction, helpAdjustPosition: Int) -> SKSpriteNode {
        let bg = SKSpriteNode(imageNamed: backgroundName)
        
        bg.anchorPoint = CGPoint(x: 0, y:0)
        
        bg.size.width = self.size.width * 2 + 1.5 //get the right pixel on phone
        bg.size.height = self.size.height
        bg.zPosition = 1 //Z positions define what itens comes in front goes from ex: 0,1,2,3 etc
        bg.position = CGPoint(x: self.size.width * CGFloat(helpAdjustPosition), y:0)
        bg.run(action)
        
        return bg
    }
    
    //Função que estrutura toda a parte do background animado
    func creatingAnimatedBackground() {
        let moveBackground = SKAction.moveBy(x: -self.size.width * 2, y: 0, duration: 10)
        
        self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: moveBackground, helpAdjustPosition: 0)
        self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: moveBackground, helpAdjustPosition: 2)
        
        self.backgroundChoosedToTransition = self.backgroundDia1
        
        self.addChild(backgroundDia1)
        self.addChild(backgroundDia2)
    
    }
    
    func removeActionsAndParentsOfBackgrounds() {
        self.backgroundDia1.removeFromParent()
        self.backgroundDia2.removeFromParent()
        self.backgroundDia1.removeAllActions()
        self.backgroundDia2.removeAllActions()
    }
    
    func swappingBetweenDayAndNight(to nightOrDay: String) {
        if nightOrDay == "night" {
            //setando transitionDay a day como false para fazer a transição para noite
            self.day = false
            self.transitionDay = false
            self.startedTransitionDay = false
            
            self.night = true
            
            //Setando tempo de transição de background para o tempo atual
            self.timeOfChangingBackground = .now + 15
        } else {
            //setando transitionDay a day como false para fazer a transição para noite
            self.night = false
            self.transitionNight = false
            self.startedTransitionNight = false

            self.day = true

            //Setando tempo de transição de background para o tempo atual
            self.timeOfChangingBackground = .now + 8

        }
    }
    
    func swapBackgroundsWithTransitionFalse(with background1Or2Swapping: Int, at nightOrDay: String, action: SKAction) {
        if nightOrDay == "day" {
            if background1Or2Swapping == 1 {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 2)

                self.backgroundChoosedToTransition = self.backgroundDia2

                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            } else {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 2)

                self.backgroundChoosedToTransition = self.backgroundDia1

                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            }
        } else if nightOrDay == "night" {
            if background1Or2Swapping == 1 {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia2
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            } else {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia1
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            }
        }
    }
    
    func swappingBeforeStartingTransitionDependingOnTheBackGroundChoosed(at nightOrDay: String, action: SKAction) {
        if nightOrDay == "day" {
            if self.backgroundChoosedToTransition == self.backgroundDia1 {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_dia", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia1
            } else {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_dia", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia2
            }
            
            self.addChild(self.backgroundDia1)
            self.addChild(self.backgroundDia2)
            
            self.startedTransitionDay = true
        } else {
            if self.backgroundChoosedToTransition == self.backgroundDia1 {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia1
            } else {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia2
            }
            
            self.addChild(self.backgroundDia1)
            self.addChild(self.backgroundDia2)
            
            self.startedTransitionNight = true
        
        }
    }
    
    
    func executingTheTransitionOfTheBackgrounds(with background1Or2Choosed: Int, at nightOrDay: String, action: SKAction) {
        if nightOrDay == "day" {
            if background1Or2Choosed == 1 {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_dia", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia1
                
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            } else {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_dia", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_noite", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia2
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            }
        } else if nightOrDay == "night" {
            if background1Or2Choosed == 1 {
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia1
                
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            } else {
                self.backgroundDia2 = self.structuringBackgroundAndApplyingAction(backgroundName: "background_transicao_noite", action: action, helpAdjustPosition: 0)
                self.backgroundDia1 = self.structuringBackgroundAndApplyingAction(backgroundName: "bg", action: action, helpAdjustPosition: 2)
                
                self.backgroundChoosedToTransition = self.backgroundDia2
                
                self.addChild(self.backgroundDia1)
                self.addChild(self.backgroundDia2)
            }
        }
    }
    
    //Função que será acionada no update para verificar a posicao dos backgrounds e continuar a animação
    func verifyAndMoveBackground() {
        let moveBackground = SKAction.moveBy(x: -self.size.width * 2, y: 0, duration: 10)
        
        if self.day {
            if !self.transitionDay { //Condição de geração de backgrounds antes de começar a transição
                if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                    self.removeActionsAndParentsOfBackgrounds()
                    self.swapBackgroundsWithTransitionFalse(with: 1, at: "day", action: moveBackground)
                } else if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                    self.removeActionsAndParentsOfBackgrounds()
                    self.swapBackgroundsWithTransitionFalse(with: 2, at: "day", action: moveBackground)
                }
            } else { // Else para começar a transição
                if !self.startedTransitionDay { //Enquanto não começou a transição ele ve qual foi o background escolhido para fazer o swap e faz tal ação (swap)
                    if self.backgroundChoosedToTransition!.position.x <= -self.size.width * 2 + 1 {
                        self.removeActionsAndParentsOfBackgrounds()
                        self.swappingBeforeStartingTransitionDependingOnTheBackGroundChoosed(at: "day", action: moveBackground)
                    }
                } else { // Else para o começo da transição
                    if self.backgroundChoosedToTransition == self.backgroundDia1 { //Se o background escolhido é o 1, então vai fazer a transição verificando as posições dos backgorunds
                        if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                            self.removeActionsAndParentsOfBackgrounds()
                            self.executingTheTransitionOfTheBackgrounds(with: 1, at: "day", action: moveBackground)
                        } else if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                            self.swappingBetweenDayAndNight(to: "night")
                        }
                    } else if self.backgroundChoosedToTransition == self.backgroundDia2 { //Se o background escolhido é o 2, então vai fazer a transição verificando as posições dos backgorunds
                        if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                            self.removeActionsAndParentsOfBackgrounds()
                            self.executingTheTransitionOfTheBackgrounds(with: 2, at: "day", action: moveBackground)
                        } else if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                            self.swappingBetweenDayAndNight(to: "night")
                        }
                    }
                }
            }
        } else if self.night {
            if !self.transitionNight {//Condição de geração de backgrounds antes de começar a transição
                if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                    self.removeActionsAndParentsOfBackgrounds()
                    self.swapBackgroundsWithTransitionFalse(with: 1, at: "night", action: moveBackground)
                } else if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                    self.removeActionsAndParentsOfBackgrounds()
                    self.swapBackgroundsWithTransitionFalse(with: 2, at: "night", action: moveBackground)
                }
            } else { // Else para começar a transição
                if !self.startedTransitionNight { //Enquanto não começou a transição ele ve qual foi o background escolhido para fazer o swap e faz tal ação (swap)
                    if self.backgroundChoosedToTransition!.position.x <= -self.size.width * 2 + 1 {
                        self.removeActionsAndParentsOfBackgrounds()
                        self.swappingBeforeStartingTransitionDependingOnTheBackGroundChoosed(at: "night", action: moveBackground)
                    }
                } else { // Else para o começo da transição
                    if self.backgroundChoosedToTransition == self.backgroundDia1 {//Se o background escolhido é o 1, então vai fazer a transição verificando as posições dos backgorunds
                        if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                            self.removeActionsAndParentsOfBackgrounds()
                            self.executingTheTransitionOfTheBackgrounds(with: 1, at: "night", action: moveBackground)
                        } else if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                            self.swappingBetweenDayAndNight(to: "day")
                        }
                    } else if self.backgroundChoosedToTransition == self.backgroundDia2 { //Se o background escolhido é o 2, então vai fazer a transição verificando as posições dos backgorunds
                        if self.backgroundDia1.position.x <= -self.size.width * 2 + 1 {
                            self.removeActionsAndParentsOfBackgrounds()
                            self.executingTheTransitionOfTheBackgrounds(with: 2, at: "night", action: moveBackground)
                        } else if self.backgroundDia2.position.x <= -self.size.width * 2 + 1 {
                            self.swappingBetweenDayAndNight(to: "day")
                        }
                    }
                }
            }
        }
    }
    
    
    //Criando função que implementa dificuldade com o decorrer do jogo
    func increasingLevel() {
        if Score.shared.gameScore == 10 {
            self.deleteActionsAndObstacles()
            self.creatingMoveOfObstacle(tempo: 2.0, duration: 0.0035)
        } else if Score.shared.gameScore == 30 {
            self.deleteActionsAndObstacles()
            self.creatingMoveOfObstacle(tempo: 1.8, duration: 0.0030)
        } else if Score.shared.gameScore == 70 {
            self.deleteActionsAndObstacles()
            self.creatingMoveOfObstacle(tempo: 1.5, duration: 0.0025)
        } else if Score.shared.gameScore == 130 {
            self.deleteActionsAndObstacles()
            self.creatingMoveOfObstacle(tempo: 1.0, duration: 0.0020)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if .now >= self.timeToWaitForMusic + 0.1 {
            if !self.timeMusicPlayed {
                self.menu?.menuToPlayMusicBackground()
                self.timeMusicPlayed = true
            }
            
        }
        
        if menu!.startGame == true{
            if !gameOver && !pausedGame {
                
                self.verifyPrize()
                
                prizeLblGame.text = "\(prizeGame)"
                
                if currentTime > Score.shared.renderTime{
                    Score.shared.addScore()
                    Score.shared.trySaveHighScore()
                    Score.shared.scoreLabel.text = "\(Score.shared.gameScore)"
                    Score.shared.renderTime = currentTime + Score.shared.changeTime
                    
                    menu!.highScoreText.text = "\(Score.shared.highScore)"
                    
                    self.increasingLevel()
                }
            }
        }
        
        if self.gameStarted {
            
            //Lógica para ajudar nas transmissões
            if self.day {
                if .now >= self.timeOfChangingBackground {
                    self.transitionDay = true
                }
            }
            
            if self.night {
                if .now >= self.timeOfChangingBackground {
                    self.transitionNight = true
                }
            }
            
        }
        
        self.verifyAndMoveBackground()
        
        self.monsterAppear()

    }
}
