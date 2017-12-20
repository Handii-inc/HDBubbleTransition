import Foundation

/**
 For concreate class for using in self.present.
 */
class Present: TransitionMode {
    public func accept(_ visitor: TransitionModeVisitor,
                       in transitionContext: UIViewControllerContextTransitioning)
    {
        visitor.transition(at: self, in: transitionContext)
    }
}
