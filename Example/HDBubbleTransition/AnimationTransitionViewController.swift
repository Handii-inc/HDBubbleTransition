import UIKit
import HDBubbleTransition

class AnimationTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    private let appearFrom: CGPoint
    
    private lazy var backGround: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self,
                         action: #selector(self.trantision(sender:)),
                         for: .touchUpInside)
        button.backgroundColor = .purple
        return button
    }()
    
    init(appearFrom: CGPoint)
    {
        self.appearFrom = appearFrom
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        self.view.addSubview(self.backGround)
        self.view.addSubview(self.button)
    }

    override func viewWillLayoutSubviews() {
        self.backGround.frame = UIScreen.main.bounds
        
        let diameter: CGFloat = 50
        let gapFromBottom: CGFloat = self.backGround.frame.height * 0.75
        self.button.frame = CGRect(x: (self.backGround.frame.width - diameter) * 0.5,
                                   y: self.backGround.frame.height - diameter - gapFromBottom,
                                   width: diameter,
                                   height: diameter)
        self.button.layer.cornerRadius = diameter * 0.5
        
        return
    }
    
    @objc private func trantision(sender: UIButton)
    {
        if sender.isEqual(self.button) {
            self.dismiss(animated: true)
            return
        }
        return
    }
    
    //MARK:- UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return HDBubbleTransition.appear(from: self.appearFrom,
                                         in: self.view.frame,
                                         with: 0.5,
                                         colored: self.backGround.backgroundColor ?? .clear)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return HDBubbleTransition.disappear(to: self.button.center,
                                            in: self.view.frame,
                                            with: 0.5,
                                            colored: self.backGround.backgroundColor ?? .clear)
    }


}
