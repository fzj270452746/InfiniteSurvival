

import UIKit

internal class JuaoybView: UIView {
    
    // 按钮操作闭包
    var jsoeun: (() -> Void)?
    var lspoiv: (() -> Void)?
    
    // 子按钮
    private var shangxjiun: UIButton!
    private var xigeugr: UIButton?
    private var huxiange: UIButton?
    
    // 按钮状态
    private var isMenuExpanded = false
    private let animationDuration = 0.3
    private let subButtonSize: CGFloat = 50
    private let spacing: CGFloat = 10
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shangxjiun = UIButton(type: .system)
        shangxjiun.tintColor = .systemBlue
        shangxjiun.backgroundColor = .white
        shangxjiun.layer.cornerRadius = 25
        shangxjiun.layer.shadowColor = UIColor.black.cgColor
        shangxjiun.layer.shadowOffset = CGSize(width: 0, height: 2)
        shangxjiun.layer.shadowOpacity = 0.3
        shangxjiun.layer.shadowRadius = 4
        shangxjiun.addTarget(self, action: #selector(dioMjsea), for: .touchUpInside)
        shangxjiun.frame = CGRectMake(0, 0, 50, 50)
        addSubview(shangxjiun)
        
        self.bounds.size = CGSize(width: 50, height: 50)
        
        shangxjiun.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        shangxjiun.setImage(UIImage(systemName: "plus.circle.fill"), for: .highlighted)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(gtubHanhes(_:)))
        shangxjiun.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func gtubHanhes(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        if isMenuExpanded {
            inpandChilds()
            isMenuExpanded.toggle()
        }
        
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
    }

    @objc private func dioMjsea() {
        if isMenuExpanded {
            inpandChilds()
        } else {
            psimeoaj()
            expandChilds()
        }
        isMenuExpanded.toggle()
    }
    
    // MARK: - 按钮动作
    @objc private func iaposme() {
        inpandChilds()
        isMenuExpanded = false
        jsoeun?()
    }
    
    @objc private func dlaoiem() {
        inpandChilds()
        isMenuExpanded = false
        lspoiv?()
    }
    
    // 创建子按钮
    private func psimeoaj() {
        guard xigeugr == nil, huxiange == nil else { return }
        
        // 刷新按钮
        xigeugr = createSubButton(
            imageName: "arrowshape.left.circle.fill",
            color: .systemGreen,
            action: #selector(iaposme))
        
        // 首页按钮
        huxiange = createSubButton(
            imageName: "house.circle.fill",
            color: .systemPurple,
            action: #selector(dlaoiem))
    }
    
    private func createSubButton(imageName: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = color
        button.backgroundColor = .white
        button.layer.cornerRadius = subButtonSize/2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.alpha = 0
        button.frame.size = CGSize(width: subButtonSize, height: subButtonSize)
        
        superview?.addSubview(button)
//        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: subButtonSize),
            button.heightAnchor.constraint(equalToConstant: subButtonSize),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        return button
    }
    
    // 显示子按钮
    private func expandChilds() {
        guard let refreshButton = xigeugr,
              let homeButton = huxiange,
              let superview = superview else { return }
        
        // 将子按钮移到最前面
        superview.bringSubviewToFront(self)
        
        // 设置初始位置
        refreshButton.center = center
        homeButton.center = center
        
        // 动画显示
        UIView.animate(withDuration: animationDuration) {
            refreshButton.center.y = self.center.y - self.subButtonSize - self.spacing
            homeButton.center.y = refreshButton.center.y - self.subButtonSize - self.spacing
            
            
            refreshButton.alpha = 1
            homeButton.alpha = 1
        }
    }
    
    // 隐藏子按钮
    private func inpandChilds() {
        guard let refreshButton = xigeugr,
              let homeButton = huxiange else { return }
        
        UIView.animate(withDuration: animationDuration, animations: {
            refreshButton.center = self.center
            homeButton.center = self.center
            
            refreshButton.alpha = 0
            homeButton.alpha = 0
        }) { _ in
            refreshButton.removeFromSuperview()
            homeButton.removeFromSuperview()
            self.xigeugr = nil
            self.huxiange = nil
        }
    }
    
 
}
