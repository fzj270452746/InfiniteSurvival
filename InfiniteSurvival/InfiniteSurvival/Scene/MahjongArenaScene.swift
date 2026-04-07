//
//  MahjongArenaScene.swift
//  InfiniteSurvival
//
//  Main SpriteKit game scene for tile pool and hand management
//

import SpriteKit

// MARK: - Scene Delegate
protocol MahjongArenaSceneDelegate: AnyObject {
    func arenaDidSelectTiles(_ scene: MahjongArenaScene, selectedIndices: [Int])
    func arenaDidRequestDraw(_ scene: MahjongArenaScene)
    func arenaDidRequestDiscard(_ scene: MahjongArenaScene, tileIndex: Int)
}

class MahjongArenaScene: SKScene {

    // MARK: - Properties
    weak var arenaDelegate: MahjongArenaSceneDelegate?

    private var tileSprites: [CeramicTileSprite] = []
    private var selectedTileIndices: Set<Int> = []

    private let handContainer = SKNode()
    private let pondContainer = SKNode()
    private let backgroundLayer = SKNode()

    // Tile pool visual (face-down deck)
    private let deckCountLabel = SKLabelNode()
    private var deckSprites: [SKSpriteNode] = []

    // Layout constants
    private var handAreaY: CGFloat = 0
    private var pondAreaY: CGFloat = 0

    // Particle
    private var ambientParticleEmitter: SKEmitterNode?

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(cgColor: PrismPaletteProvider.canvasBackdrop.cgColor)
        setupBackgroundElements()
        setupContainers()
        setupAmbientParticles()
    }

    // MARK: - Background
    private func setupBackgroundElements() {
        // Subtle grid pattern
        let gridSize: CGFloat = 40
        let gridNode = SKNode()
        gridNode.alpha = 0.03
        gridNode.zPosition = -10

        let cols = Int(size.width / gridSize) + 1
        let rows = Int(size.height / gridSize) + 1

        for col in 0...cols {
            let x = CGFloat(col) * gridSize
            let line = SKShapeNode(rectOf: CGSize(width: 0.5, height: size.height))
            line.fillColor = .white
            line.strokeColor = .clear
            line.position = CGPoint(x: x, y: size.height / 2)
            gridNode.addChild(line)
        }
        for row in 0...rows {
            let y = CGFloat(row) * gridSize
            let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 0.5))
            line.fillColor = .white
            line.strokeColor = .clear
            line.position = CGPoint(x: size.width / 2, y: y)
            gridNode.addChild(line)
        }

        addChild(gridNode)
    }

    // MARK: - Containers
    private func setupContainers() {
        // Hand area at bottom (above button area)
        handAreaY = size.height * 0.12
        handContainer.position = CGPoint(x: 0, y: handAreaY)
        handContainer.zPosition = 10
        addChild(handContainer)

        // Tile pond in center
        pondAreaY = size.height * 0.48
        pondContainer.position = CGPoint(x: size.width / 2, y: pondAreaY)
        pondContainer.zPosition = 5
        addChild(pondContainer)

        setupDeckVisual()
    }

    // MARK: - Deck Visual
    private func setupDeckVisual() {
        // Stack of face-down tiles representing the draw pile
        let deckBaseX: CGFloat = 0
        let deckBaseY: CGFloat = 0
        let coverTexture = SKTexture(imageNamed: "is_cover")
        let cardSize = CGSize(width: 50, height: 70)

        for i in 0..<3 {
            let cardBack = SKSpriteNode(texture: coverTexture, size: cardSize)
            cardBack.position = CGPoint(x: deckBaseX + CGFloat(i) * 3, y: deckBaseY + CGFloat(i) * 3)
            cardBack.zPosition = CGFloat(i)
            pondContainer.addChild(cardBack)
            deckSprites.append(cardBack)
        }

        // Count label
        deckCountLabel.fontName = "HelveticaNeue-Bold"
        deckCountLabel.fontSize = 13
        deckCountLabel.fontColor = SKColor(cgColor: PrismPaletteProvider.textSecondary.cgColor)
        deckCountLabel.position = CGPoint(x: deckBaseX, y: deckBaseY - 55)
        deckCountLabel.zPosition = 5
        pondContainer.addChild(deckCountLabel)

        // Draw instruction
        let tapHint = SKLabelNode(text: "TAP TO DRAW")
        tapHint.fontName = "HelveticaNeue-Medium"
        tapHint.fontSize = 10
        tapHint.fontColor = SKColor(cgColor: PrismPaletteProvider.textMuted.cgColor)
        tapHint.position = CGPoint(x: deckBaseX, y: deckBaseY - 73)
        tapHint.zPosition = 5
        tapHint.name = "drawHint"

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ]))
        tapHint.run(pulse)

        pondContainer.addChild(tapHint)
    }

    func refreshDeckCount(_ count: Int) {
        deckCountLabel.text = "\(count) tiles left"
    }

    // MARK: - Ambient Particles
    private func setupAmbientParticles() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.particleBirthRate = 2
        emitter.particleLifetime = 6
        emitter.particleColor = SKColor(cgColor: PrismPaletteProvider.accentLuminance.cgColor)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.15
        emitter.particleAlphaSpeed = -0.02
        emitter.particleScale = 0.08
        emitter.particleScaleSpeed = -0.01
        emitter.particleSpeed = 15
        emitter.particleSpeedRange = 10
        emitter.emissionAngleRange = .pi * 2
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        emitter.zPosition = -5
        addChild(emitter)
        ambientParticleEmitter = emitter
    }

    // MARK: - Hand Display
    func renderHandTiles(_ tiles: [CeramicTileUnit]) {
        // Clear existing
        handContainer.removeAllChildren()
        tileSprites.removeAll()
        selectedTileIndices.removeAll()

        guard !tiles.isEmpty else { return }

        // Max 20 tiles, 6 per row, max 4 rows
        let displayTiles = Array(tiles.prefix(20))
        let tilesPerRow = 6
        let tileSize = CeramicTileSprite.preferredTileSize(forScreenWidth: size.width, handCount: max(displayTiles.count, tilesPerRow))
        let totalRows = min(4, Int(ceil(Double(displayTiles.count) / Double(tilesPerRow))))
        let spacing: CGFloat = 6

        for (index, tile) in displayTiles.enumerated() {
            let row = index / tilesPerRow
            guard row < 4 else { break }
            let col = index % tilesPerRow
            let tilesInThisRow = min(tilesPerRow, displayTiles.count - row * tilesPerRow)

            let rowWidth = CGFloat(tilesInThisRow) * tileSize.width + CGFloat(tilesInThisRow - 1) * spacing
            let startX = (size.width - rowWidth) / 2 + tileSize.width / 2

            let x = startX + CGFloat(col) * (tileSize.width + spacing)
            let y = CGFloat(totalRows - 1 - row) * (tileSize.height + spacing + 4)

            let sprite = CeramicTileSprite(tile: tile, index: index, tileSize: tileSize)
            sprite.position = CGPoint(x: x, y: y)
            sprite.animateEntrance(delay: Double(index) * 0.04)

            handContainer.addChild(sprite)
            tileSprites.append(sprite)
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check deck tap
        let pondLocation = touch.location(in: pondContainer)
        if abs(pondLocation.x) < 40 && abs(pondLocation.y) < 50 {
            arenaDelegate?.arenaDidRequestDraw(self)
            animateDeckDraw()
            return
        }

        // Check tile tap
        let handLocation = touch.location(in: handContainer)
        for sprite in tileSprites {
            if sprite.contains(handLocation) {
                sprite.toggleSelectionState()
                if sprite.isMarkedSelected {
                    selectedTileIndices.insert(sprite.handSlotIndex)
                } else {
                    selectedTileIndices.remove(sprite.handSlotIndex)
                }

                arenaDelegate?.arenaDidSelectTiles(self, selectedIndices: Array(selectedTileIndices))
                return
            }
        }
    }

    // MARK: - Deck Draw Animation
    private func animateDeckDraw() {
        let coverTexture = SKTexture(imageNamed: "is_cover")
        let cardClone = SKSpriteNode(texture: coverTexture, size: CGSize(width: 50, height: 70))
        cardClone.position = CGPoint(x: 6, y: 6)
        cardClone.zPosition = 20
        pondContainer.addChild(cardClone)

        let moveToHand = SKAction.move(to: CGPoint(x: 0, y: -(pondAreaY - handAreaY) + 40), duration: 0.4)
        moveToHand.timingMode = .easeInEaseOut

        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        cardClone.run(SKAction.sequence([moveToHand, fadeOut, SKAction.removeFromParent()]))
    }

    // MARK: - Selection Reset
    func clearAllSelections() {
        selectedTileIndices.removeAll()
        for sprite in tileSprites {
            sprite.forceDeselect()
        }
    }

    func retrieveSelectedIndices() -> [Int] {
        return Array(selectedTileIndices).sorted()
    }

    // MARK: - Meld Celebration
    func playMeldCelebration(pattern: MeldPatternKind, atIndices indices: [Int]) {
        for index in indices {
            guard index < tileSprites.count else { continue }
            let sprite = tileSprites[index]

            // Particle burst
            let burstEmitter = SKEmitterNode()
            burstEmitter.particleBirthRate = 40
            burstEmitter.numParticlesToEmit = 20
            burstEmitter.particleLifetime = 0.8
            burstEmitter.particleColor = .yellow
            burstEmitter.particleColorBlendFactor = 1.0
            burstEmitter.particleAlpha = 0.8
            burstEmitter.particleAlphaSpeed = -1.0
            burstEmitter.particleScale = 0.04
            burstEmitter.particleScaleSpeed = -0.04
            burstEmitter.particleSpeed = 60
            burstEmitter.emissionAngleRange = .pi * 2
            burstEmitter.position = sprite.position
            burstEmitter.zPosition = 50
            handContainer.addChild(burstEmitter)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                burstEmitter.removeFromParent()
            }
        }

        // Pattern label flash
        let patternLabel = SKLabelNode(text: pattern.displayTitle)
        patternLabel.fontName = "HelveticaNeue-Bold"
        patternLabel.fontSize = 28
        patternLabel.fontColor = .yellow
        patternLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        patternLabel.zPosition = 100
        patternLabel.alpha = 0
        patternLabel.setScale(0.5)
        addChild(patternLabel)

        let subtitleLabel = SKLabelNode(text: pattern.displayCaption)
        subtitleLabel.fontName = "HelveticaNeue-Medium"
        subtitleLabel.fontSize = 16
        subtitleLabel.fontColor = SKColor(cgColor: PrismPaletteProvider.textSecondary.cgColor)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35 - 30)
        subtitleLabel.zPosition = 100
        subtitleLabel.alpha = 0
        addChild(subtitleLabel)

        let showAction = SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.2, duration: 0.3)
        ])
        let shrink = SKAction.scale(to: 1.0, duration: 0.15)
        let holdAction = SKAction.wait(forDuration: 1.0)
        let hideAction = SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        ])

        patternLabel.run(SKAction.sequence([showAction, shrink, holdAction, hideAction, SKAction.removeFromParent()]))
        subtitleLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 1.15),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}
