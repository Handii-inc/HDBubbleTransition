import UIKit

/**
 Transition mode visitor interface.
 */
protocol TransitionModeVisitor {
    func transition(at mode: Present, in transitionContext: UIViewControllerContextTransitioning)
    func transition(at mode: Dismiss, in transitionContext: UIViewControllerContextTransitioning)
    
    //Don't add interface for abstract!!!
    //func transition(at _: TransitionMode, in transitionContext: UIViewControllerContextTransitioning)
}
