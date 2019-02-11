//
//  JSSAlertView
//  JSSAlertView
//
//  Created by Jay Stakelon on 9/16/14.
//	Maintained by Tomas Sykora since 2015
//  Copyright (c) 2016 / https://github.com/JSSAlertView  - all rights reserved.
//
//  Inspired by and modeled after https://github.com/vikmeup/SCLAlertView-Swift
//  by Victor Radchenko: https://github.com/vikmeup
//

import Foundation
import UIKit

/// Enum describing Text Color theme
///
/// - dark: Dark Text Color theme
/// - light: Light Text Color theme
public enum TextColorTheme {
    case dark, light
}

public struct JSSViewConfgiuration {
    let cornerRadius: CGFloat
    let color: UIColor
    
    public init (color: UIColor, radius: CGFloat) {
        self.color = color
        cornerRadius = radius
    }    
}

public struct JSSTextConfgiuration {
    var textFontName: String = "SFUIText-Regular"
    var textFont: UIFont? = UIFont.systemFont(ofSize: 16, weight: .regular)
    var textColor: UIColor = UIColorFromHex(0x4b3c32, alpha: 1)
    
    var timerFont: String = "HelveticaNeue"
    
    var titleFontName: String = "SFUIText-Bold"
    var titleColor: UIColor = UIColorFromHex(0x4b3c32, alpha: 1)
    var titleFont: UIFont? = UIFont.systemFont(ofSize: 16, weight: .semibold)
}

public struct JSSButtonConfgiuration {
    var buttonFontName: String = "SFUIText-Semibold"
    var textColor: UIColor = UIColorFromHex(0xf18732, alpha: 1)
    var size: Int = 17
    var font: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular)
    var cancelFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .semibold)
}

public struct JSSAnimationConfiguration {
    let animate: Bool
    let delay: Double
}

/// Custom modal controller
open class JSSAlertView: UIViewController {
    
    var containerView: UIView!
    var alertBackgroundView: UIView!
    var dismissButton: UIButton!
    var cancelButton: UIButton!
    var buttonLabel: UILabel!
    var cancelButtonLabel: UILabel!
    var titleLabel: UILabel!
    var timerLabel:UILabel!
    var textView: UITextView!
    weak var rootViewController: UIViewController!
    var iconImage: UIImage!
    var titleImage: UIImage!
    var iconImageView: UIImageView!
    var titleImageView: UIImageView!
    var closeAction: (()->Void)!
    var cancelAction: (()->Void)!
    var isAlertOpen: Bool = false
    var noButtons: Bool = false
    var buttonsBackgroundView: UIView!
    
    var timeLeft: UInt?
    
    enum FontType {
        case title, text, button, timer
    }
    
    var defaultColor = UIColorFromHex(0xF2F4F4, alpha: 1)
    var darkTextColor = UIColorFromHex(0x000000, alpha: 0.75)
    var lightTextColor = UIColorFromHex(0xffffff, alpha: 0.9)
    
    public enum ActionType {
        case close, cancel
    }
    
    let baseHeight: CGFloat = 226.0
    var alertWidth: CGFloat = 294.0
    let buttonHeight: CGFloat = 44.0
    var padding: CGFloat = 20.0
    var titleAndMessagePadding: CGFloat = 0
    let maxTextHeight: CGFloat = 274.0
    
    var viewWidth: CGFloat?
    var viewHeight: CGFloat?
    var textMinimumLineHeight: CGFloat?
    
    var viewConfig: JSSViewConfgiuration = JSSViewConfgiuration(color: UIColor.clear,
                                                                radius: 0.0)
    var textConfig: JSSTextConfgiuration = JSSTextConfgiuration()
    var buttonConfig: JSSButtonConfgiuration = JSSButtonConfgiuration()
    
    let defaultCornerRadius: CGFloat = 4.0
    
    var animationConfig: JSSAnimationConfiguration?
    
    // Allow alerts to be closed/renamed in a chainable manner
    
    //MARK: Initializators
    
    /// Public contructor overriding parent
    ///
    /// - Parameters:
    ///   - nibNameOrNil: Nib name is never used, should be always nil, there is no nib in JSSAlertView
    ///   - nibBundleOrNil: Nib bundle is never used there is no nib bundle in JJSAlertView Controller
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Recolors text to given color
    ///
    /// - Parameter color: Color to be recolored to
    func recolorText(_ color: UIColor) {
        titleLabel.textColor = color
        if textView != nil {
            textView.textColor = color
        }
        if timerLabel != nil {
            timerLabel.textColor = color
        }
        if self.noButtons == false {
            buttonLabel.textColor = color
            if cancelButtonLabel != nil {
                cancelButtonLabel.textColor = color
            }
        }
        
    }

    public func setPaddingAndSize(padding: CGFloat, titleAndMessagePadding: CGFloat = 0, alertWidth: CGFloat) {
        self.alertWidth = alertWidth
        self.padding = padding
        self.titleAndMessagePadding = titleAndMessagePadding
    }

    public func setTextPadding(_ value: CGFloat) {
        textMinimumLineHeight = value
        if textView != nil {
            textView.setLineSpacing(minimumLineHeight: value)
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = self.rootViewControllerSize()
        self.viewWidth = size.width
        self.viewHeight = size.height

        var yPos: CGFloat = 24.0
        var xPos: CGFloat = padding
        let contentWidth:CGFloat = self.alertWidth - (self.padding*2)

        // position the icon image view, if there is one
        if self.iconImageView != nil {
            yPos += iconImageView.frame.height
            let centerX = (self.alertWidth-self.iconImageView.frame.width)/2
            iconImageView.frame = CGRect(x: centerX, y: 24, width: 64, height: 64)
            yPos += 16
        }

        // position the title
        let titleString = titleLabel.text! as NSString
        let titleAttr = [NSAttributedStringKey.font: titleLabel.font!]
        let titleSize = CGSize(width: contentWidth, height: 90)
        let titleRect = titleString.boundingRect(with: titleSize, options: .usesLineFragmentOrigin, attributes: titleAttr, context: nil)
        if self.titleImageView != nil {
            titleImageView.frame = CGRect(x: padding + 4, y: yPos + 4, width: 27, height: 27)
            xPos += 16 + 27
        }
        titleLabel.frame = CGRect(x: xPos, y: yPos, width: alertWidth - (padding * 2), height: ceil(titleRect.height))
        yPos += ceil(titleRect.height) + titleAndMessagePadding

        // position text
        if self.textView != nil {
            let realSize = textView.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude))
            var textHeight = realSize.height
            if textHeight > maxTextHeight {
                textHeight = maxTextHeight
                textView.isScrollEnabled = true
                textView.isUserInteractionEnabled = true
            }
            textView.frame = CGRect(x: padding, y: yPos, width: alertWidth - (padding * 2), height: textHeight)
            yPos += textHeight
        }

        // position timer
        if self.timerLabel != nil {
            let timerString = timerLabel.text! as NSString
            let timerSize = CGSize(width: contentWidth, height: 20)
            let timerRect = timerString.boundingRect(with: timerSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: titleAttr, context: nil)
            self.timerLabel.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: ceil(timerRect.size.height))
            yPos += ceil(timerRect.size.height)
        }

        // position the buttons

        if !noButtons {
            yPos += padding
            var buttonWidth = alertWidth
            if cancelButton != nil {
                buttonWidth = alertWidth / 2
                cancelButton.frame = CGRect(x: 0, y: yPos, width: buttonWidth - 0.5, height: buttonHeight)
                if cancelButtonLabel != nil {
                    cancelButtonLabel.frame = CGRect(x: padding, y: (buttonHeight / 2) - 15, width: buttonWidth - (padding * 2), height: 30)
                }
            }

            let buttonX = buttonWidth == alertWidth ? 0 : buttonWidth
            dismissButton.frame = CGRect(x: buttonX, y: yPos, width: buttonWidth, height: buttonHeight)
            if buttonLabel != nil {
                buttonLabel.frame = CGRect(x: padding, y: (buttonHeight / 2) - 15, width: buttonWidth - (padding * 2), height: 30)
            }

            // set button fonts
            if buttonLabel != nil {
                buttonLabel.font = buttonConfig.font
                buttonLabel.textColor = buttonConfig.textColor
            }
            if cancelButtonLabel != nil {
                cancelButtonLabel.font = buttonConfig.cancelFont
                cancelButtonLabel.textColor = buttonConfig.textColor
            }
            buttonsBackgroundView.frame = CGRect(x: 0, y: yPos - 1, width: alertWidth, height: buttonHeight + 1)
            yPos += buttonHeight
        }else{
            yPos += padding
        }

        // size the background view
        alertBackgroundView.frame = CGRect(x: 0, y: 0, width: alertWidth, height: yPos)

        // size the container that holds everything together
        containerView.frame = CGRect(x: (viewWidth! - alertWidth) / 2, y: (viewHeight! - yPos)/2, width: alertWidth, height: yPos)
    }
    
    
    
    // MARK: - Main Show Method
    
    /// Main method for rendering JSSAlertViewController
    ///
    ///
    /// - Parameters:
    ///   - viewController: ViewController above which JSSAlertView will be shown
    ///   - title: JSSAlertView title
    ///   - text: JSSAlertView text
    ///   - noButtons: Option for no buttons, ehen activated, it gets closed by tap
    ///   - buttonText: Button text
    ///   - cancelButtonText: Cancel button text
    ///   - color: JSSAlertView color
    ///   - iconImage: Image which gets placed above title
    ///   - delay: Delay after which JSSAlertView automatically disapears
    ///   - timeLeft: Counter aka Tinder counter shows time in seconds
    /// - Returns: returns JSSAlertViewResponder
    @discardableResult
    public func show(_ viewController: UIViewController,
                     title: String,
                     text: String?=nil,
                     noButtons: Bool = false,
                     buttonText: String? = nil,
                     cancelButtonText: String? = nil,
                     buttonsConfig: JSSButtonConfgiuration? = nil,
                     viewConfig: JSSViewConfgiuration? = nil,
                     iconImage: UIImage? = nil,
                     titleImage: UIImage? = nil,
                     delay: Double? = nil,
                     timeLeft: UInt? = nil,
                     textAlignment: NSTextAlignment = .center) -> JSSAlertViewResponder {

        rootViewController = viewController
        view.backgroundColor = UIColorFromHex(0x000000, alpha: 0.7)

        var baseColor: UIColor = defaultColor
        var cornerRadius: CGFloat = defaultCornerRadius

        if let config = viewConfig {
            baseColor = config.color
            cornerRadius = config.cornerRadius
        }
        
        if let btnConfig = buttonsConfig {
            self.buttonConfig = btnConfig
        }
        
        let textColor = darkTextColor

        let sz = screenSize()
        viewWidth = sz.width
        viewHeight = sz.height

        view.frame.size = sz

        // Container for the entire alert modal contents
        containerView = UIView()
        view.addSubview(containerView!)
        // Background view/main color
        alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = baseColor
        alertBackgroundView.layer.cornerRadius = cornerRadius
        alertBackgroundView.layer.masksToBounds = true
        containerView.addSubview(alertBackgroundView!)

        // Icon
        self.iconImage = iconImage
        if iconImage != nil {
            iconImageView = UIImageView(image: iconImage)
            iconImageView.contentMode = UIViewContentMode.scaleAspectFit
            containerView.addSubview(iconImageView)
        }
        // TitleIcon
        self.titleImage = titleImage
        if titleImage != nil {
            titleImageView = UIImageView(image: titleImage)
            titleImageView.contentMode = UIViewContentMode.scaleAspectFit
            containerView.addSubview(titleImageView)
        }

        // Title
        titleLabel = UILabel()
        titleLabel.textColor = textConfig.titleColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = textAlignment
        titleLabel.font = textConfig.titleFont
        titleLabel.text = title
        containerView.addSubview(titleLabel)

        // View text
        if let text = text {
            textView = UITextView()
            textView.isUserInteractionEnabled = false
            textView.isEditable = false
            textView.textColor = textConfig.textColor
            textView.textAlignment = textAlignment
            textView.font = textConfig.textFont
            textView.backgroundColor = UIColor.clear
            textView.text = text
            if let lineHeight = textMinimumLineHeight {
                textView.setLineSpacing(minimumLineHeight: lineHeight)
            }
            containerView.addSubview(textView)
        }

        //timer
        if let time = timeLeft {
            self.timerLabel = UILabel()
            timerLabel.textAlignment = .center
            self.timeLeft = time
            self.timerLabel.font = UIFont(name: textConfig.timerFont, size: 27)
            self.timerLabel.textColor = textColor
            self.containerView.addSubview(timerLabel)
            configureTimer()
        }

        // Button
        self.noButtons = true
        let buttonColor = UIImage.with(color: adjustBrightness(UIColor.white, amount: 1.0))
        if !noButtons {
            buttonsBackgroundView = UIView()
            buttonsBackgroundView.backgroundColor = UIColorFromHex(0xe7e2de, alpha: 0.7)
            alertBackgroundView!.addSubview(buttonsBackgroundView)

            self.noButtons = false
            dismissButton = UIButton()
            let buttonHighlightColor = UIImage.with(color: adjustBrightness(baseColor, amount: 0.9))
            dismissButton.setBackgroundImage(buttonColor, for: .normal)
            dismissButton.setBackgroundImage(buttonHighlightColor, for: .highlighted)
            dismissButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
            alertBackgroundView!.addSubview(dismissButton)
            // Button text
            buttonLabel = UILabel()
            buttonLabel.textColor = buttonConfig.textColor
            buttonLabel.numberOfLines = 1
            buttonLabel.textAlignment = .center
            if let text = buttonText {
                buttonLabel.text = text
            } else {
                buttonLabel.text = "OK"
            }
            dismissButton.addSubview(buttonLabel)

            // Second cancel button
            if cancelButtonText != nil {
                cancelButton = UIButton()
                let buttonHighlightColor = UIImage.with(color: adjustBrightness(baseColor, amount: 0.9))
                cancelButton.setBackgroundImage(buttonColor, for: .normal)
                cancelButton.setBackgroundImage(buttonHighlightColor, for: .highlighted)
                cancelButton.addTarget(self, action: #selector(JSSAlertView.cancelButtonTap), for: .touchUpInside)
                alertBackgroundView!.addSubview(cancelButton)
                // Button text
                cancelButtonLabel = UILabel()
                cancelButtonLabel.alpha = 1.0
                cancelButtonLabel.textColor = buttonConfig.textColor
                cancelButtonLabel.numberOfLines = 1
                cancelButtonLabel.textAlignment = .center
                cancelButtonLabel.text = cancelButtonText
                cancelButtonLabel.font = buttonConfig.cancelFont
                cancelButton.addSubview(cancelButtonLabel)
            }
        }

        // Animate it in
        view.alpha = 0
        definesPresentationContext = true
        modalPresentationStyle = .overFullScreen

        if let config = animationConfig {
            showAlertWithAnimation(source: viewController, config: config)
        } else {
            showAlertWithAnimation(source: viewController, delay: delay)
        }


        return JSSAlertViewResponder(alertview: self)

    }
    
    fileprivate func showAlertWithAnimation(source viewController: UIViewController,
                                            config: JSSAnimationConfiguration) {
        viewController.present(self, animated: false, completion: {
            // Animate it in
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 1
            }
            self.containerView.center.x = self.view.center.x
            self.containerView.center = self.view.center
            self.isAlertOpen = true
        })
    }
    
    fileprivate func showAlertWithAnimation(source viewController: UIViewController, delay: Double?) {
        viewController.present(self, animated: false, completion: {
            // Animate it in
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 0.3
            }
            
//            self.containerView.center.x = self.view.center.x
//            self.containerView.center.y = -500
            
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
//                self.containerView.center = self.view.center
                self.view.alpha = 1.0
            }, completion: { finished in
                self.isAlertOpen = true
                if let d = delay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + d, execute: {
                        self.closeView(true)
                    })
                }
            })
        })
    }
    
    /// Adding action for button which is not cancel button
    ///
    /// - Parameter action: func which gets executed when disapearing
    func addAction(_ action: @escaping () -> Void) {
        self.closeAction = action
    }
    
    
    /// Method for removing JSSAlertView from view when there are no buttons
    @objc func buttonTap() {
        closeView(true, source: .close);
    }
    
    
    /// Adds action as a function which gets executed when cancel button is tapped
    ///
    /// - Parameter action: func which gets executed
    func addCancelAction(_ action: @escaping () -> Void) {
        self.cancelAction = action
    }
    
    
    /// Cancel button tap
    @objc func cancelButtonTap() {
        closeView(true, source: .cancel);
    }
    
    
    /// Removes view
    ///
    /// - Parameters:
    ///   - withCallback: callback availabel
    ///   - source: Type of removing view see ActionType
    public func closeView(_ withCallback: Bool, source: ActionType = .close) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
//            self.containerView.center.y = self.view.center.y + self.viewHeight!
        }, completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {
                self.view.alpha = 0
            }, completion: { finished in
                self.dismiss(animated: false, completion: {
                    
                    if withCallback {
                        if let action = self.closeAction , source == .close {
                            action()
                        }
                        else if let action = self.cancelAction, source == .cancel {
                            action()
                        }
                    }
                })
            })
        })
    }
    
    
    /// Removes view from superview
    func removeView() {
        isAlertOpen = false
        removeFromParentViewController()
        view.removeFromSuperview()
    }
    
    
    /// Returns rootViewControllers size
    ///
    /// - Returns: root view controller size
    func rootViewControllerSize() -> CGSize {
        let size = rootViewController.view.frame.size
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            return CGSize(width: size.height, height: size.width)
        }
        return size
    }
    
    
    /// Gets screen size
    ///
    /// - Returns: screen size
    func screenSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            return CGSize(width: screenSize.height, height: screenSize.width)
        }
        return screenSize
    }
    
    
    /// Tracks touches used when there are no buttons to remove view
    ///
    /// - Parameters:
    ///   - touches: touched actions form user
    ///   - event: touches event
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let locationPoint = touch.location(in: view)
            let converted = containerView.convert(locationPoint, from: view)
            if containerView.point(inside: converted, with: event){
                if noButtons {
                    closeView(true, source: .cancel)
                }
                
            }
        }
    }
    
    //MARK: - Memory management
    
    /// Memory management not actually needed
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - Setters
extension JSSAlertView {
    
    /// Sets Font
    ///
    /// - Parameters:
    ///   - fontStr: name of font
    ///   - type: target to set font to e.g. title, text ...
    func setFont(_ fontStr: String, type: FontType, size: CGFloat? = nil) {
        switch type {
        case .title:
            textConfig.titleFontName = fontStr
            if let font = UIFont(name: textConfig.titleFontName, size: size ?? 24) {
                self.titleLabel.font = font
            } else {
                self.titleLabel.font = UIFont.systemFont(ofSize: size ?? 24)
            }
        case .text:
            if self.textView != nil {
                textConfig.textFontName = fontStr
                if let font = UIFont(name: textConfig.textFontName, size: size ?? 16) {
                    self.textView.font = font
                } else {
                    self.textView.font = UIFont.systemFont(ofSize: size ?? 16)
                }
            }
        case .button:
            buttonConfig.buttonFontName = fontStr
            if let font = UIFont(name: buttonConfig.buttonFontName, size: size ?? 24) {
                self.buttonLabel.font = font
            } else {
                self.buttonLabel.font = UIFont.systemFont(ofSize: size ?? 24)
            }
        case .timer:
            textConfig.timerFont = fontStr
            if let font = UIFont(name: textConfig.timerFont, size: size ?? 27) {
                self.buttonLabel.font = font
            } else {
                self.buttonLabel.font = UIFont.systemFont(ofSize: size ?? 27)
            }
        }
        // relayout to account for size changes
        self.viewDidLayoutSubviews()
    }
    
    
    /// Sets theme
    ///
    /// - Parameter theme: TextColorTheme
    func setTextTheme(_ theme: TextColorTheme) {
        switch theme {
        case .light:
            recolorText(lightTextColor)
        case .dark:
            recolorText(darkTextColor)
        }
    }
}

extension UITextView {

    func setLineSpacing(minimumLineHeight: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = minimumLineHeight

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
}
