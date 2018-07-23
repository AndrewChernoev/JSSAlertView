//
//  JSSAlertViewResponder.swift
//  Pods
//
//  Created by Tomas Sykora, jr. on 05/11/2016.
//
//

import UIKit


/// Repsonder for user interaction
open class JSSAlertViewResponder {
    let alertview: JSSAlertView


    /// Contructor
    ///
    /// - Parameter alertview: constructs it self from JSSAlertView
    public init(alertview: JSSAlertView) {
        self.alertview = alertview
    }

    /// Adds button action
    ///
    /// - Parameter action: func to be run as action when button is tapped
    open func addAction(_ action: @escaping ()->Void) {
        self.alertview.addAction(action)
    }

    /// Adds cancel action
    ///
    /// - Parameter action: func to be run when cancel button is tapped
    open func addCancelAction(_ action: @escaping ()->Void) {
        self.alertview.addCancelAction(action)
    }


    /// Sets Title Font
    ///
    /// - Parameter fontStr: Font name
    open func setTitleFont(_ fontStr: String, size: CGFloat? = nil) {
        self.alertview.setFont(fontStr, type: .title, size: size)
    }

    /// Sets text font
    ///
    /// - Parameter fontStr: Font name
    open func setTextFont(_ fontStr: String, size: CGFloat? = nil) {
        self.alertview.setFont(fontStr, type: .text, size: size)
    }

    /// Sets Timer font
    ///
    /// - Parameter fontStr: Font name
    open func setTimerFont(_ fontStr: String, size: CGFloat? = nil) {
        self.alertview.setFont(fontStr, type: .timer, size: size)
    }


    /// Sets button Font
    ///
    /// - Parameter fontStr: Font name
    open func setButtonFont(_ fontStr: String, size: CGFloat? = nil) {
        self.alertview.setFont(fontStr, type: .button, size: size)
    }


    /// Sets text theme
    ///
    /// - Parameter theme: TextColorTheme
    open func setTextTheme(_ theme: TextColorTheme) {
        self.alertview.setTextTheme(theme)
    }


    /// Close action to remove from superview
    @objc func close() {
        self.alertview.closeView(false)
    }
}
