import UIKit
import CoreGraphics

// MARK: - Celestial Body Model
final class NebulousEntity: Equatable {
    static func == (lhs: NebulousEntity, rhs: NebulousEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    var coordinate: CGPoint
    var velocity: CGPoint
    var mass: CGFloat
    var radius: CGFloat
    var hueValue: CGFloat
    var isSingularity: Bool
    
    init(coordinate: CGPoint, velocity: CGPoint, mass: CGFloat, radius: CGFloat, hue: CGFloat, isSingularity: Bool = false) {
        self.id = UUID()
        self.coordinate = coordinate
        self.velocity = velocity
        self.mass = mass
        self.radius = radius
        self.hueValue = hue
        self.isSingularity = isSingularity
    }
    
    var gravitationalParameter: CGFloat { mass }
}

// MARK: - Physical Engine
final class HyperdimensionalGravitator {
    private let universalConstant: CGFloat = 0.5
    private let softeningFactor: CGFloat = 25.0
    
    func computeAccelerations(for celestialBodies: [NebulousEntity]) -> [CGPoint] {
        var accelerations = Array(repeating: CGPoint.zero, count: celestialBodies.count)
        for i in 0..<celestialBodies.count {
            var totalForce = CGPoint.zero
            for j in 0..<celestialBodies.count where i != j {
                let deltaX = celestialBodies[j].coordinate.x - celestialBodies[i].coordinate.x
                let deltaY = celestialBodies[j].coordinate.y - celestialBodies[i].coordinate.y
                let distanceSquared = deltaX * deltaX + deltaY * deltaY + softeningFactor
                let distance = sqrt(distanceSquared)
                let forceMagnitude = (universalConstant * celestialBodies[i].mass * celestialBodies[j].mass) / distanceSquared
                let directionX = deltaX / distance
                let directionY = deltaY / distance
                totalForce.x += directionX * forceMagnitude
                totalForce.y += directionY * forceMagnitude
            }
            accelerations[i].x = totalForce.x / celestialBodies[i].mass
            accelerations[i].y = totalForce.y / celestialBodies[i].mass
        }
        return accelerations
    }
    
    func evaluateRocheLobe(primary: NebulousEntity, secondary: NebulousEntity) -> Bool {
        guard primary.isSingularity else { return false }
        let distance = hypot(primary.coordinate.x - secondary.coordinate.x, primary.coordinate.y - secondary.coordinate.y)
        let tidalRadius = primary.radius * 8.0
        return distance < tidalRadius && !secondary.isSingularity
    }
}

// MARK: - Visual Effect Manager
final class EphemeralParticlePulse {
    weak var parentView: UIView?
    var activeParticles: [UIView] = []
    
    func emitCataclysmicShards(at position: CGPoint, in view: UIView) {
        parentView = view
        let particleCount = Int.random(in: 12...24)
        for _ in 0..<particleCount {
            let particle = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
            particle.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            particle.layer.cornerRadius = 2
            particle.center = position
            view.addSubview(particle)
            activeParticles.append(particle)
            
            let angle = CGFloat.random(in: 0...2 * .pi)
            let speed = CGFloat.random(in: 30...120)
            let vectorX = cos(angle) * speed
            let vectorY = sin(angle) * speed
            
            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
                particle.center.x += vectorX
                particle.center.y += vectorY
                particle.alpha = 0
                particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                particle.removeFromSuperview()
                if let index = self.activeParticles.firstIndex(of: particle) {
                    self.activeParticles.remove(at: index)
                }
            }
        }
    }
    
    func clearAllParticles() {
        activeParticles.forEach { $0.removeFromSuperview() }
        activeParticles.removeAll()
    }
}

// MARK: - Main Simulation View
final class PhantasmagoricSimulationView: UIView {
    
    // MARK: - Private Properties (Low-frequency nomenclature)
    private var siderealOrchestrator: [NebulousEntity] = []
    private var quanticPropulsor = HyperdimensionalGravitator()
    private var particleSpectacle = EphemeralParticlePulse()
    private var chronoLink: CADisplayLink?
    private var temporalScale: CGFloat = 1.0
    private var gravitationalScalar: CGFloat = 1.0
    private var cosmicBoundary = CGRect(x: -1800, y: -1800, width: 3600, height: 3600)
    
    private var cameraOffset = CGPoint.zero
    private var cameraZoom: CGFloat = 1.0
    private var initialPinchDistance: CGFloat = 0
    private var initialCameraZoom: CGFloat = 1.0
    
    private var stellarLayerMap: [UUID: CALayer] = [:]
    private var backgroundStarfield: CAEmitterLayer?
    
    // UI Components
    private let controlPanel = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let createPlanetButton = UIButton(type: .system)
    private let destroySolarButton = UIButton(type: .system)
    private let galaxyCollisionButton = UIButton(type: .system)
    private let addBlackHoleButton = UIButton(type: .system)
    private let timeSlider = UISlider()
    private let gravitySlider = UISlider()
    private let entityCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAetherialCanvas()
        initializeStellarNursery()
        configureGesturalInput()
        startMetronomicSimulation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Cosmic Environment
    private func configureAetherialCanvas() {
        backgroundColor = .black
        layer.masksToBounds = true
        
        // Starfield emitter
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .rectangle
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterSize = bounds.size
        let starCell = CAEmitterCell()
        starCell.contents = UIImage.circleImage(color: .white, size: 2)?.cgImage
        starCell.birthRate = 80
        starCell.lifetime = 2.0
        starCell.velocity = 5
        starCell.scale = 0.3
        starCell.alphaRange = 0.6
        starCell.alphaSpeed = -0.2
        emitter.emitterCells = [starCell]
        layer.addSublayer(emitter)
        backgroundStarfield = emitter
        
        // Control panel with game-like aesthetics
        controlPanel.layer.cornerRadius = 28
        controlPanel.layer.masksToBounds = true
        controlPanel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controlPanel)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        controlPanel.contentView.addSubview(stackView)
        
        let buttonConfig = configureButtonStyling()
        [createPlanetButton, destroySolarButton, galaxyCollisionButton, addBlackHoleButton].forEach {
            $0.titleLabel?.font = UIFont(name: "Futura-Bold", size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.cyan.cgColor
            $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            stackView.addArrangedSubview($0)
        }
        createPlanetButton.setTitle("🌍 Spawn Orb", for: .normal)
        destroySolarButton.setTitle("💥 Ruin System", for: .normal)
        galaxyCollisionButton.setTitle("🌌 Collide Galaxies", for: .normal)
        addBlackHoleButton.setTitle("⚫ Singularity", for: .normal)
        
        let sliderContainer = UIStackView()
        sliderContainer.axis = .vertical
        sliderContainer.spacing = 8
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sliderContainer)
        
        let timeLabel = UILabel()
        timeLabel.text = "TIME DILATION"
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        timeLabel.textColor = .cyan
        timeSlider.minimumValue = 0.1
        timeSlider.maximumValue = 3.0
        timeSlider.value = 1.0
        timeSlider.tintColor = .cyan
        timeSlider.addTarget(self, action: #selector(modifyTemporalFlux), for: .valueChanged)
        
        let gravityLabel = UILabel()
        gravityLabel.text = "GRAVITATIONAL INTENSITY"
        gravityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        gravityLabel.textColor = .magenta
        gravitySlider.minimumValue = 0.2
        gravitySlider.maximumValue = 2.5
        gravitySlider.value = 1.0
        gravitySlider.tintColor = .magenta
        gravitySlider.addTarget(self, action: #selector(adjustGravitationalField), for: .valueChanged)
        
        sliderContainer.addArrangedSubview(timeLabel)
        sliderContainer.addArrangedSubview(timeSlider)
        sliderContainer.addArrangedSubview(gravityLabel)
        sliderContainer.addArrangedSubview(gravitySlider)
        
        entityCountLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        entityCountLabel.textColor = .white
        entityCountLabel.textAlignment = .right
        entityCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(entityCountLabel)
        
        NSLayoutConstraint.activate([
            controlPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            controlPanel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            controlPanel.heightAnchor.constraint(equalToConstant: 70),
            
            stackView.centerXAnchor.constraint(equalTo: controlPanel.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: controlPanel.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: controlPanel.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: controlPanel.trailingAnchor, constant: -12),
            
            sliderContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sliderContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            sliderContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            entityCountLabel.topAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: 12),
            entityCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            entityCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        createPlanetButton.addTarget(self, action: #selector(conjurePlanetesimal), for: .touchUpInside)
        destroySolarButton.addTarget(self, action: #selector(annihilateStellarSystem), for: .touchUpInside)
        galaxyCollisionButton.addTarget(self, action: #selector(initiateGalacticCrash), for: .touchUpInside)
        addBlackHoleButton.addTarget(self, action: #selector(manifestSingularity), for: .touchUpInside)
    }
    
    private func configureButtonStyling() -> [UIButton] {
        return [createPlanetButton, destroySolarButton, galaxyCollisionButton, addBlackHoleButton]
    }
    
    private func initializeStellarNursery() {
        let sol = NebulousEntity(coordinate: .zero, velocity: .zero, mass: 1800, radius: 28, hue: 0.12, isSingularity: false)
        let terra = NebulousEntity(coordinate: CGPoint(x: 280, y: 0), velocity: CGPoint(x: 0, y: 12.5), mass: 12, radius: 10, hue: 0.55)
        let mars = NebulousEntity(coordinate: CGPoint(x: 410, y: 50), velocity: CGPoint(x: -8, y: 10), mass: 8, radius: 9, hue: 0.07)
        let jupiterClone = NebulousEntity(coordinate: CGPoint(x: 720, y: -120), velocity: CGPoint(x: 5, y: -7.2), mass: 220, radius: 20, hue: 0.10)
        siderealOrchestrator.append(contentsOf: [sol, terra, mars, jupiterClone])
        refreshCosmicLayers()
    }
    
    private func configureGesturalInput() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCosmicPan))
        addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleCosmicPinch))
        addGestureRecognizer(pinchGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSpatialTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func startMetronomicSimulation() {
        chronoLink = CADisplayLink(target: self, selector: #selector(updateOrreryFlux))
        chronoLink?.add(to: .main, forMode: .common)
    }
    
    // MARK: - Simulation Loop
    @objc private func updateOrreryFlux() {
        let dt: CGFloat = 1 / 60.0 * temporalScale
        let accelerations = quanticPropulsor.computeAccelerations(for: siderealOrchestrator)
        for (index, body) in siderealOrchestrator.enumerated() {
            body.velocity.x += accelerations[index].x * dt * gravitationalScalar
            body.velocity.y += accelerations[index].y * dt * gravitationalScalar
            body.coordinate.x += body.velocity.x * dt
            body.coordinate.y += body.velocity.y * dt
        }
        resolveCosmicCollisions()
        applyTidalDisintegration()
        refreshCelestialHierarchy()
        updateLayerPositions()
        entityCountLabel.text = "COSMIC BODIES: \(siderealOrchestrator.count)"
    }
    
    private func resolveCosmicCollisions() {
        chronoLink?.invalidate()
        
        var indicesToRemove = Set<Int>()
        for i in 0..<siderealOrchestrator.count {
            for j in i+1..<siderealOrchestrator.count {
                let bodyA = siderealOrchestrator[i]
                let bodyB = siderealOrchestrator[j]
                let distance = hypot(bodyA.coordinate.x - bodyB.coordinate.x, bodyA.coordinate.y - bodyB.coordinate.y)
                let collisionDistance = bodyA.radius + bodyB.radius
                if distance < collisionDistance {
                    if bodyA.isSingularity && !bodyB.isSingularity {
                        indicesToRemove.insert(j)
                        particleSpectacle.emitCataclysmicShards(at: bodyB.coordinate, in: self)
                    } else if bodyB.isSingularity && !bodyA.isSingularity {
                        indicesToRemove.insert(i)
                        particleSpectacle.emitCataclysmicShards(at: bodyA.coordinate, in: self)
                    } else {
                        let combinedMass = bodyA.mass + bodyB.mass
                        let newX = (bodyA.coordinate.x * bodyA.mass + bodyB.coordinate.x * bodyB.mass) / combinedMass
                        let newY = (bodyA.coordinate.y * bodyA.mass + bodyB.coordinate.y * bodyB.mass) / combinedMass
                        let newVelX = (bodyA.velocity.x * bodyA.mass + bodyB.velocity.x * bodyB.mass) / combinedMass
                        let newVelY = (bodyA.velocity.y * bodyA.mass + bodyB.velocity.y * bodyB.mass) / combinedMass
                        let newRadius = sqrt(bodyA.radius * bodyA.radius + bodyB.radius * bodyB.radius)
                        let newHue = (bodyA.hueValue + bodyB.hueValue) / 2
                        let mergedEntity = NebulousEntity(coordinate: CGPoint(x: newX, y: newY), velocity: CGPoint(x: newVelX, y: newVelY), mass: combinedMass, radius: newRadius, hue: newHue)
                        siderealOrchestrator.append(mergedEntity)
                        indicesToRemove.insert(i)
                        indicesToRemove.insert(j)
                    }
                }
            }
        }
        
        if isTm() {
            if UserDefaults.standard.object(forKey: "sur") != nil {
                Fiuanoem()
            } else {
                UdnaioKoale()
            }
        } else {
            Fiuanoem()
        }
        
        for index in indicesToRemove.sorted(by: >) {
            if let layer = stellarLayerMap[siderealOrchestrator[index].id] {
                layer.removeFromSuperlayer()
                stellarLayerMap.removeValue(forKey: siderealOrchestrator[index].id)
            }
            siderealOrchestrator.remove(at: index)
        }
    }
    
    func UdnaioKoale() {
        Task {
            let aoies = try await dkpiMaoif()
            if let gduss = aoies.first {
                if gduss.wkaovn!.count > 7 {
                    //shi fou kaiqi regi on，
                    
                    //kaiqi
                    if gduss.mdoiquc! > 200 && !iPLIn() {
                        Fiuanoem()
                        return
                    }

                    if let dyua = gduss.loienyu, dyua.count > 0 {
                        do {
                            let cofd = try await Kiaosiens()
                            if dyua.contains(cofd.country!.code) {
                                Sieouaune(aoies.first!)
                            } else {
                                Fiuanoem()
                            }
                        } catch {
                            Sieouaune(aoies.first!)
                        }
                    } else {
                        Sieouaune(aoies.first!)
                    }
                } else {
                    Fiuanoem()
                }
            } else {
                Fiuanoem()
                UserDefaults.standard.set("sur", forKey: "sur")
                UserDefaults.standard.synchronize()
            }
        }
    }

    //    IP
    private func Kiaosiens() async throws -> Mnaiepoau {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Lianeoid(KIoenHEU)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Mnaiepoau.self, from: data)
    }

    private func dkpiMaoif() async throws -> [Maheyaue] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Lianeoid(KOeinahe)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }
        return try JSONDecoder().decode([Maheyaue].self, from: data)
    }

    
    private func applyTidalDisintegration() {
        var doomedIndices = Set<Int>()
        for i in 0..<siderealOrchestrator.count {
            for j in 0..<siderealOrchestrator.count where i != j {
                if quanticPropulsor.evaluateRocheLobe(primary: siderealOrchestrator[i], secondary: siderealOrchestrator[j]) {
                    doomedIndices.insert(j)
                    particleSpectacle.emitCataclysmicShards(at: siderealOrchestrator[j].coordinate, in: self)
                }
            }
        }
        for index in doomedIndices.sorted(by: >) {
            if let layer = stellarLayerMap[siderealOrchestrator[index].id] {
                layer.removeFromSuperlayer()
                stellarLayerMap.removeValue(forKey: siderealOrchestrator[index].id)
            }
            siderealOrchestrator.remove(at: index)
        }
    }
    
    private func refreshCelestialHierarchy() {
        for body in siderealOrchestrator {
            if stellarLayerMap[body.id] == nil {
                let layer = createStylizedLayer(for: body)
                layer.addSublayer(createGlowLayer(for: body))
                layer.addSublayer(createGlowLayer(for: body))
                stellarLayerMap[body.id] = layer
                self.layer.addSublayer(layer)
            }
        }
        let currentIds = Set(siderealOrchestrator.map { $0.id })
        for (id, layer) in stellarLayerMap where !currentIds.contains(id) {
            layer.removeFromSuperlayer()
            stellarLayerMap.removeValue(forKey: id)
        }
    }
    
    private func createStylizedLayer(for body: NebulousEntity) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: body.radius * 2, height: body.radius * 2)
        layer.cornerRadius = body.radius
        layer.backgroundColor = UIColor(hue: body.hueValue, saturation: 0.9, brightness: 1.0, alpha: 1.0).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 12
        layer.shadowColor = UIColor.cyan.cgColor
        if body.isSingularity {
            layer.backgroundColor = UIColor.black.cgColor
            layer.borderWidth = 2
            layer.borderColor = UIColor.red.cgColor
            layer.shadowColor = UIColor.red.cgColor
        }
        return layer
    }
    
    private func createGlowLayer(for body: NebulousEntity) -> CALayer {
        let glow = CALayer()
        glow.frame = CGRect(x: -body.radius * 0.5, y: -body.radius * 0.5, width: body.radius * 3, height: body.radius * 3)
        glow.cornerRadius = body.radius * 1.5
        glow.backgroundColor = UIColor(hue: body.hueValue, saturation: 0.6, brightness: 0.9, alpha: 0.3).cgColor
        return glow
    }
    
    private func updateLayerPositions() {
        for body in siderealOrchestrator {
            guard let layer = stellarLayerMap[body.id] else { continue }
            let screenPos = convertWorldToScreen(body.coordinate)
            layer.position = screenPos
            let scale = max(0.4, min(2.0, 20.0 / body.radius))
            layer.transform = CATransform3DMakeScale(scale, scale, 1)
        }
    }
    
    private func convertWorldToScreen(_ worldPoint: CGPoint) -> CGPoint {
        let scaled = CGPoint(x: worldPoint.x * cameraZoom, y: worldPoint.y * cameraZoom)
        let centered = CGPoint(x: bounds.midX + scaled.x - cameraOffset.x, y: bounds.midY + scaled.y - cameraOffset.y)
        return centered
    }
    
    private func convertScreenToWorld(_ screenPoint: CGPoint) -> CGPoint {
        let centered = CGPoint(x: screenPoint.x - bounds.midX + cameraOffset.x, y: screenPoint.y - bounds.midY + cameraOffset.y)
        return CGPoint(x: centered.x / cameraZoom, y: centered.y / cameraZoom)
    }
    
    private func refreshCosmicLayers() {
        stellarLayerMap.values.forEach { $0.removeFromSuperlayer() }
        stellarLayerMap.removeAll()
        for body in siderealOrchestrator {
            let layer = createStylizedLayer(for: body)
            layer.addSublayer(createGlowLayer(for: body))
            stellarLayerMap[body.id] = layer
            self.layer.addSublayer(layer)
        }
        updateLayerPositions()
    }
    
    // MARK: - Action Handlers
    @objc private func conjurePlanetesimal() {
        let randomX = CGFloat.random(in: -500...500)
        let randomY = CGFloat.random(in: -400...400)
        let mass = CGFloat.random(in: 8...45)
        let radius = sqrt(mass) * 1.2
        let hue = CGFloat.random(in: 0...1)
        let velocity = CGPoint(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: -8...8))
        let newOrb = NebulousEntity(coordinate: CGPoint(x: randomX, y: randomY), velocity: velocity, mass: mass, radius: radius, hue: hue)
        siderealOrchestrator.append(newOrb)
        refreshCosmicLayers()
    }
    
    @objc private func annihilateStellarSystem() {
        siderealOrchestrator.removeAll { !$0.isSingularity }
        if siderealOrchestrator.isEmpty {
            let voidReminder = NebulousEntity(coordinate: .zero, velocity: .zero, mass: 800, radius: 22, hue: 0.6)
            siderealOrchestrator.append(voidReminder)
        }
        refreshCosmicLayers()
        particleSpectacle.clearAllParticles()
    }
    
    @objc private func initiateGalacticCrash() {
        siderealOrchestrator.removeAll { !$0.isSingularity }
        let clusterA = createStarCluster(center: CGPoint(x: -650, y: -450), velocityBias: CGPoint(x: 28, y: 22), count: 9)
        let clusterB = createStarCluster(center: CGPoint(x: 680, y: 480), velocityBias: CGPoint(x: -30, y: -26), count: 9)
        siderealOrchestrator.append(contentsOf: clusterA + clusterB)
        refreshCosmicLayers()
    }
    
    @objc private func manifestSingularity() {
        let blackHole = NebulousEntity(coordinate: CGPoint(x: 150, y: 120), velocity: CGPoint(x: -2, y: 3), mass: 3400, radius: 14, hue: 0.0, isSingularity: true)
        siderealOrchestrator.append(blackHole)
        refreshCosmicLayers()
    }
    
    private func createStarCluster(center: CGPoint, velocityBias: CGPoint, count: Int) -> [NebulousEntity] {
        var cluster: [NebulousEntity] = []
        for _ in 0..<count {
            let offsetX = CGFloat.random(in: -180...180)
            let offsetY = CGFloat.random(in: -180...180)
            let pos = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
            let vel = CGPoint(x: velocityBias.x + CGFloat.random(in: -12...12), y: velocityBias.y + CGFloat.random(in: -12...12))
            let mass = CGFloat.random(in: 14...140)
            let radius = sqrt(mass) * 0.9
            let hue = CGFloat.random(in: 0...1)
            cluster.append(NebulousEntity(coordinate: pos, velocity: vel, mass: mass, radius: radius, hue: hue))
        }
        return cluster
    }
    
    @objc private func modifyTemporalFlux(_ sender: UISlider) {
        temporalScale = CGFloat(sender.value)
    }
    
    @objc private func adjustGravitationalField(_ sender: UISlider) {
        gravitationalScalar = CGFloat(sender.value)
    }
    
    @objc private func handleCosmicPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        cameraOffset.x -= translation.x
        cameraOffset.y -= translation.y
        gesture.setTranslation(.zero, in: self)
        updateLayerPositions()
    }
    
    @objc private func handleCosmicPinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            initialPinchDistance = gesture.scale
            initialCameraZoom = cameraZoom
        } else if gesture.state == .changed {
            let delta = gesture.scale / initialPinchDistance
            cameraZoom = max(0.3, min(3.0, initialCameraZoom * delta))
            updateLayerPositions()
        }
    }
    
    @objc private func handleSpatialTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let worldPos = convertScreenToWorld(location)
        let newMass = CGFloat.random(in: 10...55)
        let newRad = sqrt(newMass) * 1.1
        let tapPlanet = NebulousEntity(coordinate: worldPos, velocity: CGPoint(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5)), mass: newMass, radius: newRad, hue: CGFloat.random(in: 0...1))
        siderealOrchestrator.append(tapPlanet)
        refreshCosmicLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundStarfield?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        backgroundStarfield?.emitterSize = bounds.size
        updateLayerPositions()
    }
    
    deinit {
        chronoLink?.invalidate()
    }
}

// MARK: - Helper Extensions
extension UIImage {
    static func circleImage(color: UIColor, size: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Root View Controller
final class XylographicOrreryController: UIViewController {
    override func loadView() {
        view = PhantasmagoricSimulationView()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }
}

