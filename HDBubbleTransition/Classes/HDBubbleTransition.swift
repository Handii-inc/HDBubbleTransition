import UIKit

/**
 You can add bubble transition animation to view controller.
 Step by step:
 - Add UIViewControllerTransitioningDelegate to UIViewContorller that is going to present.
 - In function of UIViewControllerTransitioningDelegate, return HDBubbleTransition instance.
    - In for presentation implementation, create instance by HDBubbleTransition.appear.
    - In for dismiss implementation, create instance by HDBubbleTransition.disappear.
 */
open class HDBubbleTransition: NSObject, UIViewControllerAnimatedTransitioning, TransitionModeVisitor {
    //MARK:- Properties
    private let mode: TransitionMode
    private let bounds: CGRect
    private let keyPoint: CGPoint
    private let duration: Double
    private let bubbleColor: UIColor
    
    private lazy var radiusOfBubble: CGFloat = {
        let lengthOfXAxis: CGFloat = max(self.keyPoint.x, self.bounds.width - self.keyPoint.x)
        let lengthOfYAxis: CGFloat = max(self.keyPoint.y, self.bounds.height - self.keyPoint.y)
        return sqrt(lengthOfXAxis * lengthOfXAxis + lengthOfYAxis * lengthOfYAxis)
    }()
    
    private lazy var diameterOfBubble: CGFloat = {
        return self.radiusOfBubble * 2
    }()
    
    private static let miniSize: CGAffineTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    
    //MARK:- Initializer
    /**
     Create instance for presentation implementation
     - Parameters:
        - from: appear from this input
        - in: display bounds
        - with: duration of animating
        - colored: color of bubble
     */
    public static func appear(from keyPoint: CGPoint,
                              in bounds: CGRect,
                              with duration: Double,
                              colored bubbleColor: UIColor) -> UIViewControllerAnimatedTransitioning
    {
        return HDBubbleTransition(mode: Present(),
                                  bounds: bounds,
                                  keyPoint: keyPoint,
                                  duration: duration,
                                  bubbleColor: bubbleColor)
    }

    /**
     Create instance for dismiss implementation
     - Parameters:
         - to: disappear to this input
         - in: display bounds
         - with: duration of animating
         - colored: color of bubble
     */
    public static func disappear(to keyPoint: CGPoint,
                                 in bounds: CGRect,
                                 with duration: Double,
                                 colored bubbleColor: UIColor) -> UIViewControllerAnimatedTransitioning
    {
        return HDBubbleTransition(mode: Dismiss(),
                                  bounds: bounds,
                                  keyPoint: keyPoint,
                                  duration: duration,
                                  bubbleColor: bubbleColor)
    }

    private init(mode: TransitionMode,
                 bounds: CGRect,
                 keyPoint: CGPoint,
                 duration: Double,
                 bubbleColor: UIColor)
    {
        self.mode = mode
        self.bounds = bounds
        self.keyPoint = keyPoint
        self.duration = duration
        self.bubbleColor = bubbleColor
    }
    
    //MARK:- UIViewControllerAnimatedTransitioning
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return self.duration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        self.mode.accept(self, in: transitionContext)   //Please see the area of TransitionModeVisitor.
        return
    }
    
    //MARK:- TransitionModeVisitor
    /**
     This function plays the animation at the time of presenting.
     Following is the overview.
        - Preparation:
            1. Add bubble view that is shrinked as very small object.
            2. Save the point of the center of the view that is going to present.
            3. Add the view that is going to present with shrinking as very small object and locating the center of it at the key point.
        - Animating:
            - Smoothly expanding the bubble view.
            - Smoothly expanding the view that is going to present to original size, and at the same time move to original center that was stored before.
        - Completion:
            - Remove the bubble and the view where we had moved.
     */
    func transition(at mode: Present,
                    in transitionContext: UIViewControllerContextTransitioning)
    {
        guard let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        let bubble = createBubble(with: HDBubbleTransition.miniSize)
        self.setSubViews(fromView: fromView,
                         toView: toView,
                         bubble: bubble,
                         to: transitionContext.containerView,
                         at: mode)
        
        let originalCenter = toView.center
        self.prepare(appearing: toView, at: mode)
        
        transitionContext.viewController(forKey: .to)?.beginAppearanceTransition(true, animated: false)
        UIView.animate(withDuration: self.duration,
                       animations: { [unowned self] () -> Void in
                            bubble.transform = .identity
                            self.during(presenting: toView, moveTo: originalCenter, at: mode)
                       },
                       completion: { [unowned self] (_: Bool) -> Void in
                            self.completion(of: mode, in: transitionContext, withDeleting: bubble)
                       })

        return
    }
    
    /**
     This function plays the animation at the time of dimissing.
     Following is the overview.
     - Preparation:
         1. Add bubble view.
         2. Add the view that is going to present.
     - Animating:
         - Smoothly shrinking the bubble view.
         - Smoothly shrinking the view that is going to dismiss, and at the same time move the center to key point.
     - Completion:
        - Remove the bubble and the view where we had dismissed.
     */

    func transition(at mode: Dismiss,
                    in transitionContext: UIViewControllerContextTransitioning)
    {
        guard let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        let bubble: UIView = self.createBubble()
        
        self.setSubViews(fromView: fromView,
                         toView: toView,
                         bubble: bubble,
                         to: transitionContext.containerView,
                         at: mode)

        transitionContext.viewController(forKey: .to)?.beginAppearanceTransition(true, animated: false)
        UIView.animate(withDuration: self.duration,
                       animations: { [unowned self] () -> Void in
                            bubble.transform = HDBubbleTransition.miniSize
                            self.during(disappear: fromView, moveTo: self.keyPoint, at: mode)
                       },
                       completion: { [unowned self] (_: Bool) -> Void in
                            self.completion(of: mode, in: transitionContext, withDeleting: bubble)
                       })

        return
    }
    

    //MARK:- Privates
    private func createBubble() -> UIView
    {
        let view = UIView()
        view.frame = CGRect(origin: .zero,
                            size: CGSize(width: self.diameterOfBubble,
                                         height: self.diameterOfBubble))
        view.center = self.keyPoint
        view.layer.cornerRadius = self.radiusOfBubble
        view.backgroundColor = self.bubbleColor
        return view
    }
    
    private func createBubble(with transform: CGAffineTransform) -> UIView
    {
        let view = createBubble()
        view.transform = transform
        return view
    }
    
    private func setSubViews(fromView _: UIView,
                             toView: UIView,
                             bubble: UIView,
                             to: UIView,
                             at _: Present)
    {
        to.addSubview(bubble)
        to.addSubview(toView)
        return
    }

    private func setSubViews(fromView: UIView,
                             toView: UIView,
                             bubble: UIView,
                             to: UIView,
                             at _: Dismiss)
    {
        to.insertSubview(bubble, belowSubview: fromView)
        to.insertSubview(toView, belowSubview: bubble)
        return
    }
    
    private func prepare(appearing toView: UIView, at _: Present)
    {
        toView.center = self.keyPoint
        toView.transform = HDBubbleTransition.miniSize
        toView.alpha = 0
    }
    
    private func during(presenting view: UIView,
                        moveTo center: CGPoint,
                        at _: Present)
    {
        view.center = center
        view.transform = CGAffineTransform.identity
        view.alpha = 1
    }

    private func during(disappear view: UIView,
                        moveTo center: CGPoint,
                        at _: Dismiss)
    {
        view.center = center
        view.transform = HDBubbleTransition.miniSize
        view.alpha = 0
    }
    
    private func completion(of _: Present,
                            in transitionContext: UIViewControllerContextTransitioning,
                            withDeleting bubble: UIView) {
        bubble.removeFromSuperview()
        transitionContext.view(forKey: .from)?.removeFromSuperview()

        transitionContext.viewController(forKey: .to)?.endAppearanceTransition()
        transitionContext.completeTransition(true)
        return
    }

    private func completion(of _: Dismiss,
                            in transitionContext: UIViewControllerContextTransitioning,
                            withDeleting bubble: UIView) {
        bubble.removeFromSuperview()
        transitionContext.view(forKey: .from)?.removeFromSuperview()
        
        transitionContext.viewController(forKey: .to)?.endAppearanceTransition()
        transitionContext.completeTransition(true)

        return
    }
}
