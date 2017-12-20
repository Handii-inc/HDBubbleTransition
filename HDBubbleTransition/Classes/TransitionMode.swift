import UIKit

/**
 Transition mode interface.
 */
protocol TransitionMode {
    /**
     Accept visitor method for visitor pattern.
     - Note:
         Please implement in accordance with visitor pattern as the following.
         ```swift
         func accept(_ visitor: TransitionModeVisitor,
                     in transitionContext: UIViewControllerContextTransitioning)
         {
             visitor.transition(at: self, in: transitionContext)
         }
         ```
     */
    func accept(_ visitor: TransitionModeVisitor,
                in transitionContext: UIViewControllerContextTransitioning)
}
