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
    private let boundSize: CGSize
    private let duration: TimeInterval
    private let bubbleCenter: CGPoint
    private let bubbleColor: UIColor
    private let bubbleBorderColor: UIColor
    
    private lazy var radiusOfBubble: CGFloat = {
        let lengthOfXAxis: CGFloat = max(self.bubbleCenter.x, self.boundSize.width - self.bubbleCenter.x)
        let lengthOfYAxis: CGFloat = max(self.bubbleCenter.y, self.boundSize.height - self.bubbleCenter.y)
        return sqrt(lengthOfXAxis * lengthOfXAxis + lengthOfYAxis * lengthOfYAxis)
    }()
    
    private lazy var diameterOfBubble: CGFloat = {
        return self.radiusOfBubble * 2
    }()

    //MARK:- Initializer
    public static func colored(_ bubbleColor: UIColor) -> Builder
    {
        return Builder(bubbleColor: bubbleColor)
    }

    public static func colored(_ color: (bubble: UIColor, border: UIColor)) -> Builder
    {
        return Builder(bubbleColor: color.bubble, bubbleBorderColor: color.border)
    }
    
    public class Builder {
        private let bubbleColor: UIColor
        private let bubbleBorderColor: UIColor
        
        init(bubbleColor: UIColor,
             bubbleBorderColor: UIColor) {
            self.bubbleColor = bubbleColor
            self.bubbleBorderColor = bubbleBorderColor
        }

        convenience init(bubbleColor: UIColor) {
            self.init(bubbleColor: bubbleColor,
                      bubbleBorderColor: bubbleColor)
        }
        
        /**
         Create instance for presentation implementation
         - Parameters:
             - from: appear from this input
             - in: display bounds
             - with: duration of animating
         */
        public func appear(from center: CGPoint,
                           in bounds: CGRect,
                           with duration: Double) -> UIViewControllerAnimatedTransitioning
        {
            return HDBubbleTransition(transition: (Present(), duration),
                                      bubbleStyle: (bounds.size,
                                                    center,
                                                    self.bubbleColor,
                                                    self.bubbleBorderColor))
        }

        /**
         Create instance for dismiss implementation
         - Parameters:
             - to: disappear to this input
             - in: display bounds
             - with: duration of animating
         */
        public func disappear(to center: CGPoint,
                              in bounds: CGRect,
                              with duration: Double) -> UIViewControllerAnimatedTransitioning
        {
            return HDBubbleTransition(transition: (Dismiss(), duration),
                                      bubbleStyle: (bounds.size,
                                                    center,
                                                    self.bubbleColor,
                                                    self.bubbleBorderColor))
        }
    }
    
    private init(transition: (TransitionMode, TimeInterval),
                 bubbleStyle: (CGSize, CGPoint, UIColor, UIColor))
    {
        (self.mode, self.duration) = transition
        (self.boundSize, self.bubbleCenter, self.bubbleColor, self.bubbleBorderColor) = bubbleStyle
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
        guard let views = ViewAdapter.extract(from: transitionContext) else {
            return
        }
        
        let bubble : UIView = {
            let view = createBubble()
            Transform.minify(view)
            return view
        }()

        SubViewsManager.setSubViews(views: views, bubble: bubble, at: mode)

        let originalCenter = views.toView.center
        self.prepare(appearing: views.toView, at: mode)
        
        transitionContext.viewController(forKey: .to)?.beginAppearanceTransition(true, animated: false)
        
        let animations = Animator.create(forPresenting: views.toView,
                                         moveTo: originalCenter,
                                         withAnimationOf: bubble)
        let completion = self.createCompletion(in: transitionContext,
                                               withDeleting: bubble)
        UIView.animate(withDuration: self.duration,
                       animations: animations,
                       completion: completion)

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
        guard let views = ViewAdapter.extract(from: transitionContext) else {
            return
        }
        
        let bubble: UIView = self.createBubble()
        
        SubViewsManager.setSubViews(views: views, bubble: bubble, at: mode)

        transitionContext.viewController(forKey: .to)?.beginAppearanceTransition(true, animated: false)
        
        let animations = Animator.create(forDisappear: views.fromView,
                                         moveTo: self.bubbleCenter,
                                         withAnimationOf: bubble)
        let completion = self.createCompletion(in: transitionContext,
                                               withDeleting: bubble)
        UIView.animate(withDuration: self.duration,
                       animations: animations,
                       completion: completion)

        return
    }
    

    //MARK:- Privates
    private class ViewAdapter {
        //MARK:- Properties
        unowned var toView: UIView { get { return self.to } }
        unowned var fromView: UIView { get { return self.from } }
        unowned var containerView: UIView { get { return self.container } }

        //MARK:- Backing field
        private unowned let to: UIView
        private unowned let from: UIView
        private unowned let container: UIView
        
        //MARK:- Initializer
        static func extract(from transitionContext: UIViewControllerContextTransitioning) -> ViewAdapter?
        {
            guard let fromView = transitionContext.view(forKey: .from) else {
                return nil
            }
            guard let toView = transitionContext.view(forKey: .to) else {
                return nil
            }
            return ViewAdapter(to: toView,
                               from: fromView,
                               container: transitionContext.containerView)
        }
        
        private init(to: UIView,
                     from: UIView,
                     container: UIView)
        {
            self.to = to
            self.from = from
            self.container = container
        }
    }
    
    private func createBubble() -> UIView
    {
        let view = UIView()
        view.frame = CGRect(origin: .zero,
                            size: CGSize(width: self.diameterOfBubble,
                                         height: self.diameterOfBubble))
        view.center = self.bubbleCenter
        view.layer.cornerRadius = self.radiusOfBubble
        view.layer.borderWidth = 1
        view.layer.borderColor = self.bubbleBorderColor.cgColor
        view.backgroundColor = self.bubbleColor
        return view
    }
    
    private class SubViewsManager {
        static func setSubViews(views: ViewAdapter,
                                bubble: UIView,
                                at _: Present)
        {
            views.containerView.addSubview(bubble)
            views.containerView.addSubview(views.toView)
            return
        }
        
        static func setSubViews(views: ViewAdapter,
                                bubble: UIView,
                                at _: Dismiss)
        {
            views.containerView.insertSubview(bubble, belowSubview: views.fromView)
            views.containerView.insertSubview(views.toView, belowSubview: bubble)
            return
        }
    }
    
    private func prepare(appearing toView: UIView, 
                         at _: Present)
    {
        toView.center = self.bubbleCenter
        Transform.minify(toView)
        toView.alpha = 0
    }
    
    private class Animator {
        static func create(forPresenting view: UIView,
                           moveTo center: CGPoint,
                           withAnimationOf bubble: UIView) -> (() -> Void)
        {
            return {
                view.center = center
                view.alpha = 1
                Transform.origin(view)
                Transform.origin(bubble)
            }
        }
        
        static func create(forDisappear view: UIView,
                           moveTo center: CGPoint,
                           withAnimationOf bubble: UIView) -> (() -> Void)
        {
            return {
                view.center = center
                view.alpha = 0
                Transform.minify(view)

                Transform.minify(bubble)
            }
        }
    }
    
    private func createCompletion(in transitionContext: UIViewControllerContextTransitioning,
                                  withDeleting bubble: UIView) -> ((Bool) -> Void) {
        return { _ in
            bubble.removeFromSuperview()
            transitionContext.view(forKey: .from)?.removeFromSuperview()
            
            transitionContext.completeTransition(true)
        }
    }
    
    private class Transform {
        static func minify(_ target: UIView) {
            target.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            return
        }
        
        static func origin(_ target: UIView) {
            target.transform = .identity
            return
        }
    }
}
