//
//  ToastView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 18.10.2021.
//

import UIKit

extension UIView {
    private struct ToastKeys {
        static var timer        = "com.mhmtkrgz.toast.timer"
        static var completion   = "com.mhmtkrgz.toast.completion"
    }
    
    enum ToastType {
        case error
        case success
        
        // MARK: - Config
        var backgroundColor: UIColor {
            switch self {
            case .error:
                return .init(named: "main-red")!
            case .success:
                return .init(named: "main-green")!
            }
        }
        
        var maxWidth: CGFloat {
            return 0.9
        }
        
        var maxHeight: CGFloat {
            return 0.8
        }
        
        var image: UIImage {
            switch self {
            case .error:
                return .init(named: "toast-error")!
            case .success:
                return .init(named: "toast-success")!
            }
        }
        
        var itemPadding: CGFloat {
            return 16.0
        }
        
        var imageSize: CGSize {
            return .init(width: 25.0, height: 25.0)
        }
        
        var messageFont: UIFont {
            return .systemFont(ofSize: 16.0)
        }
        
        var messageColor: UIColor {
            switch self {
            case .error:
                return .white
            case .success:
                return .white
            }
        }
    }
    
    // MARK: - Public
    
    func showToast(_ type: ToastType, message: String, autoHide: Bool = true) {
        let toastView = createToastView(type, message: message)
        
        toastView.center = position(for: toastView, type: type)
        toastView.alpha = 0.0
    
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(toastView)
    //        self.addSubview(toastView)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                toastView.alpha = 1.0
            }) { _ in
                if autoHide {
                    let timer = Timer(timeInterval: 3.0, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toastView, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                    objc_setAssociatedObject(toastView, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
                
                if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                    completion(fromTap)
                }
            }
        }
    }
    
    private func createToastView( _ type: ToastType, message: String) -> UIView {
        let wrapperView = UIView()
        wrapperView.backgroundColor = type.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = 8.0
        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOpacity = 0.3
        wrapperView.layer.shadowRadius = 0.6
        wrapperView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
        // setup image view
        let imageView = UIImageView(image: type.image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(imageView)
        
        // setup message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.font = type.messageFont
        messageLabel.textAlignment = .left
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = type.messageColor
        messageLabel.backgroundColor = .clear
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(messageLabel)
        
        // setup image view constraints
        NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: type.imageSize.width).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: type.imageSize.height).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: wrapperView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: wrapperView, attribute: .leading, multiplier: 1, constant: type.itemPadding).isActive = true
        
        // setup message label constraints
        NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 8.0).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: wrapperView, attribute: .trailing, multiplier: 1, constant: -type.itemPadding).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .topMargin, relatedBy: .equal, toItem: wrapperView, attribute: .topMargin, multiplier: 1, constant: type.itemPadding).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .bottomMargin, relatedBy: .equal, toItem: wrapperView, attribute: .bottomMargin, multiplier: 1, constant: -type.itemPadding).isActive = true
       
        // setup message container constraints
        let maxMessageWidth =
            (self.bounds.size.width * type.maxWidth) - // max toast width
            type.itemPadding * 2 - // image view left and right paddings
            type.imageSize.width - // image view width
            type.itemPadding // message label trailing space
        
        let maxMessageSize = CGSize(width: maxMessageWidth, height: self.bounds.size.height * type.maxHeight)
        let messageSize = messageLabel.sizeThatFits(maxMessageSize)
        
        let actualMessageWidth = min(messageSize.width, maxMessageSize.width)
        let actualMessageHeight = min(messageSize.height, maxMessageSize.height)

        let wrapperWidth: CGFloat = type.itemPadding + type.imageSize.width + type.itemPadding + actualMessageWidth + type.itemPadding
        let maxImageHeight: CGFloat = type.itemPadding + type.imageSize.height + type.itemPadding
        let maxMessageHeight: CGFloat = type.itemPadding + actualMessageHeight + type.itemPadding
        let wrapperHeight: CGFloat = max(maxImageHeight, maxMessageHeight)
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        return wrapperView
    }
    
    // MARK: - Util
    
    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast, fromTap: false)
    }
    
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private func position(for toast: UIView, type: ToastType) -> CGPoint {
        if let superview = superview {
            let topPadding: CGFloat = type.itemPadding + superview.safeAreaInset.top
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
        }
        
        let topPadding: CGFloat = type.itemPadding + safeAreaInset.top
        return CGPoint(x: bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
    }
}

