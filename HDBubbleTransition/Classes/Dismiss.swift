import UIKit

/**
 For concreate class for using in self.dismiss.
 */
class Dismiss: TransitionMode {
    public func accept(_ visitor: TransitionModeVisitor,
                       in transitionContext: UIViewControllerContextTransitioning)
    {
        visitor.transition(at: self, in: transitionContext)
    }
}
