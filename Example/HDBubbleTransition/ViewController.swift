import UIKit

class ViewController: UIViewController {
    private lazy var backGround: UIView = {
        let view = UIView()
        view.backgroundColor = .purple
        return view
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self,
                         action: #selector(self.transition(sender:)),
                         for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.backGround)
        self.view.addSubview(self.button)
    }
    
    override func viewWillLayoutSubviews() {
        self.backGround.frame = UIScreen.main.bounds
        
        let diameter: CGFloat = 50
        let gapFromBottom: CGFloat = self.backGround.frame.height * 0.25
        self.button.frame = CGRect(x: (self.backGround.frame.width - diameter) * 0.5,
                                   y: self.backGround.frame.height - diameter - gapFromBottom,
                                   width: diameter,
                                   height: diameter)
        self.button.layer.cornerRadius = diameter * 0.5
        
        return
    }
    
    @objc private func transition(sender: UIButton)
    {
        if sender.isEqual(self.button) {
            let controller = AnimationTransitionViewController(appearFrom: self.button.center)
            self.present(controller, animated: true)
        }
        return
    }
}

