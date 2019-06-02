//
//  StandardKeyboardActionHandler.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

/*
 
 This action handler is used by the `KeyboardViewController`
 class by default, but can be replaced with any handler that
 implements `KeyboardActionHandler`.
 
 This action handler uses the default action blocks for each
 keyboard action, if any. You can adjust this by subclassing
 and overriding `tapAction(for:)` and `longPressAction(for:)`
 as well as `handleTap(on:)` and `handleLongPress(on:)`.
 
 You can enable haptic feedback by providing haptic feedback
 types for taps and long presses when you create an instance
 of this class. You can also adjust the standard behavior by
 overriding the two `giveHapticFeedback` functions.
 
 IMPORTANT: This class must inherit from `NSObject` in order
 to be able to set itself as the selection target, e.g. when
 saving images to the photo album.
 
 */

import UIKit

open class StandardKeyboardActionHandler: NSObject, KeyboardActionHandler {
    
    
    // MARK: - Initialization
    
    public init(
        inputViewController: UIInputViewController,
        tapHapticFeedback: HapticFeedback = .none,
        longPressHapticFeedback: HapticFeedback = .none) {
        self.inputViewController = inputViewController
        self.tapHapticFeedback = tapHapticFeedback
        self.longPressHapticFeedback = longPressHapticFeedback
    }
    
    
    // MARK: - Dependencies
    
    public private(set) weak var inputViewController: UIInputViewController?
    
    
    // MARK: - Properties
    
    private let tapHapticFeedback: HapticFeedback
    private let longPressHapticFeedback: HapticFeedback
    
    public var textDocumentProxy: UITextDocumentProxy? {
        return inputViewController?.textDocumentProxy
    }
    
    
    // MARK: - Types
    
    public typealias GestureAction = (() -> ())
    
    
    // MARK: - Actions
    
    open func tapAction(for view: UIView, action: KeyboardAction) -> GestureAction? {
        return inputViewControllerAction(for: action)
            ?? textDocumentProxyAction(for: action)
    }
    
    open func longPressAction(for view: UIView, action: KeyboardAction) -> (() -> ())? {
        return tapAction(for: view, action: action)
    }
    
    
    // MARK: - Action Handling
    
    open func handleTap(on action: KeyboardAction, view: UIView) {
        guard let tapAction = tapAction(for: view, action: action) else { return }
        giveHapticFeedbackForTap(on: action)
        tapAction()
    }
    
    open func handleLongPress(on action: KeyboardAction, view: UIView) {
        guard let longPressAction = longPressAction(for: view, action: action) else { return }
        giveHapticFeedbackForLongPress(on: action)
        longPressAction()
    }
    
    
    // MARK: - Haptic Functions
    
    open func giveHapticFeedbackForTap(on action: KeyboardAction) {
        tapHapticFeedback.trigger()
    }
    
    open func giveHapticFeedbackForLongPress(on action: KeyboardAction) {
        longPressHapticFeedback.trigger()
    }
}


// MARK: - Private Functions

private extension StandardKeyboardActionHandler {
    
    func inputViewControllerAction(for action: KeyboardAction) -> GestureAction? {
        guard let inputAction = action.standardInputViewControllerAction else { return nil }
        return { inputAction(self.inputViewController) }
    }
    
    func textDocumentProxyAction(for action: KeyboardAction) -> GestureAction? {
        guard let proxyAction = action.standardTextDocumentProxyAction else { return nil }
        return { proxyAction(self.textDocumentProxy) }
    }
}
