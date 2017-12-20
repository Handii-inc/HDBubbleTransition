# HDBubbleTransition

[![CI Status](http://img.shields.io/travis/Handii-inc/HDBubbleTransition.svg?style=flat)](https://travis-ci.org/Handii-inc/HDBubbleTransition)
[![Version](https://img.shields.io/cocoapods/v/HDBubbleTransition.svg?style=flat)](http://cocoapods.org/pods/HDBubbleTransition)
[![License](https://img.shields.io/cocoapods/l/HDBubbleTransition.svg?style=flat)](http://cocoapods.org/pods/HDBubbleTransition)
[![Platform](https://img.shields.io/cocoapods/p/HDBubbleTransition.svg?style=flat)](http://cocoapods.org/pods/HDBubbleTransition)
[![codebeat badge](https://codebeat.co/badges/60741d13-4fdb-4513-ace5-784b48164a60)](https://codebeat.co/projects/github-com-handii-inc-hdbubbletransition-master)

## Description

You can add bubble transition animation to view controller.
Inspired by [BubbleTransition](https://github.com/andreamazz/BubbleTransition)

## Installation

HDBubbleTransition is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'HDBubbleTransition'
```

## Step by step

1. Add inheritance of UIViewControllerTransitioningDelegate to UIViewContorller that is going to present.(__not controller that executes self.present__)
1. In function of UIViewControllerTransitioningDelegate, return HDBubbleTransition instance.
  - In for presentation implementation, create instance by HDBubbleTransition.appear.
  - In for dismiss implementation, create instance by HDBubbleTransition.disappear.

## Sample code
Please see [example](https://github.com/Handii-inc/HDBubbleTransition/tree/master/Example), if you want to get more detail.

```swift
import UIKit
import HDBubbleTransition

class AnimationTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self //set delegate
    }

    //MARK:- UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return HDBubbleTransition.appear(from: CGPoint(x: 100, y: 100),
                                         in: self.view.frame,
                                         with: 0.5,
                                         colored: .white)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return HDBubbleTransition.disappear(to: CGPoint(x: 100, y: 100),
                                            in: self.view.frame,
                                            with: 0.5,
                                            colored: .white)
    }
}
```

## Author

Handii, Inc., github@handii.co.jp

## License

HDBubbleTransition is available under the MIT license. See the LICENSE file for more info.
