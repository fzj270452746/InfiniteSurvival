//
//  CeramicTileSprite.swift
//  InfiniteSurvival
//
//  SpriteKit tile node with selection state
//

import SpriteKit

class CeramicTileSprite: SKSpriteNode {

    // MARK: - Properties
    let tileModel: CeramicTileUnit
    let handSlotIndex: Int
    private(set) var isMarkedSelected: Bool = false

    private let glowRing = SKShapeNode()
    private let suitIndicator = SKLabelNode()

    // MARK: - Constants
    static func preferredTileSize(forScreenWidth screenWidth: CGFloat, handCount: Int) -> CGSize {
        let maxPerRow = min(handCount, 7)
        let totalPadding: CGFloat = 16
        let spacing: CGFloat = CGFloat(maxPerRow - 1) * 4
        let availableWidth = screenWidth - totalPadding - spacing
        let tileWidth = min(availableWidth / CGFloat(maxPerRow), 58)
        let tileHeight = tileWidth * 1.4
        return CGSize(width: tileWidth, height: tileHeight)
    }

    // MARK: - Init
    init(tile: CeramicTileUnit, index: Int, tileSize: CGSize) {
        self.tileModel = tile
        self.handSlotIndex = index

        let texture = SKTexture(imageNamed: tile.assetMoniker)
        super.init(texture: texture, color: .clear, size: tileSize)

        self.name = "tile_\(index)"
        self.isUserInteractionEnabled = false
        self.zPosition = 10

        configureSuitAccent()
        configureGlowRing(tileSize: tileSize)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Visual Setup
    private func configureSuitAccent() {
        // Small colored bar at bottom of tile
        let accentBar = SKShapeNode(rectOf: CGSize(width: size.width * 0.6, height: 3), cornerRadius: 1.5)
        let uiColor = PrismPaletteProvider.tintForSuit(tileModel.vesselSuit)
        accentBar.fillColor = SKColor(cgColor: uiColor.cgColor)
        accentBar.strokeColor = .clear
        accentBar.position = CGPoint(x: 0, y: -size.height / 2 + 6)
        accentBar.zPosition = 11
        addChild(accentBar)
    }

    private func configureGlowRing(tileSize: CGSize) {
        let ringPath = CGPath(roundedRect: CGRect(
            x: -tileSize.width / 2 - 2,
            y: -tileSize.height / 2 - 2,
            width: tileSize.width + 4,
            height: tileSize.height + 4
        ), cornerWidth: 6, cornerHeight: 6, transform: nil)

        glowRing.path = ringPath
        glowRing.strokeColor = SKColor(cgColor: PrismPaletteProvider.accentEmber.cgColor)
        glowRing.lineWidth = 2
        glowRing.fillColor = .clear
        glowRing.alpha = 0
        glowRing.zPosition = 12
        glowRing.glowWidth = 4
        addChild(glowRing)
    }

    // MARK: - Selection
    func toggleSelectionState() {
        isMarkedSelected.toggle()

        if isMarkedSelected {
            let moveUp = SKAction.moveBy(x: 0, y: 12, duration: 0.15)
            moveUp.timingMode = .easeOut
            run(moveUp)
            glowRing.alpha = 1
            let pulseAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
            )
            glowRing.run(pulseAction, withKey: "pulse")
        } else {
            let moveDown = SKAction.moveBy(x: 0, y: -12, duration: 0.15)
            moveDown.timingMode = .easeOut
            run(moveDown)
            glowRing.removeAction(forKey: "pulse")
            glowRing.alpha = 0
        }
    }

    func forceDeselect() {
        if isMarkedSelected {
            isMarkedSelected = false
            glowRing.removeAction(forKey: "pulse")
            glowRing.alpha = 0
        }
    }

    // MARK: - Animations
    func animateEntrance(delay: TimeInterval) {
        alpha = 0
        setScale(0.3)
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        appear.timingMode = .easeOut
        run(SKAction.sequence([SKAction.wait(forDuration: delay), appear]))
    }

    func animateRemoval(completion: @escaping () -> Void) {
        let dissolve = SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.1, duration: 0.3),
            SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        ])
        dissolve.timingMode = .easeIn
        run(SKAction.sequence([dissolve, SKAction.removeFromParent()])) {
            completion()
        }
    }
}
