//
//  ShowAlert.swift
//  Hamla_iOS_Captain
//
//  Created by Bassant on 15/04/2024.
//

import Foundation
import UIKit

extension UIViewController: UIAlertViewDelegate{
    func showAlert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func showAlertWithCancel(message: String,
                             title: String? = nil,
                             okTitle: String = "OK",
                             cancelTitle: String = "Cancel",
                             okAction: (() -> Void)? = nil,
                             cancelAction: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: okTitle, style: .default) { _ in
            okAction?()
        }
        let cancelButton = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            cancelAction?()
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

class AlertManager {
    private var popup: UIView?
    
    func showAlert(on viewController: UIViewController, message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 180, height: 180))
        popup = UIView(frame: CGRect(x: ((self.popup?.bounds.width ?? 0) - messageLabel.bounds.width) / 2, y: 500, width: messageLabel.bounds.width, height: 20))
        popup?.backgroundColor = UIColor.darkGray
        
        // Create and configure a UILabel for the message
        
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0 // Allow multiple lines for long messages
        messageLabel.textColor = .white
        popup?.addSubview(messageLabel)

        // Show on screen
        if let popup = popup {
            viewController.view.addSubview(popup)
        }

        // Set the timer to dismiss the alert after 3 seconds
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
    }

    @objc func dismissAlert() {
        if let popup = popup {
            popup.removeFromSuperview()
        }
        popup = nil
    }
}

class Toast {
    static func show(message: String, controller: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = .white
        toastContainer.borderWidth = 1
        toastContainer.borderColor = UIColor(named: "background")
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 4
        toastContainer.clipsToBounds = true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor(named: "quaternary")
        toastLabel.textAlignment = .natural
        toastLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        window.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        // Constraints for toastLabel inside toastContainer
        let labelConstraints = [
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 15),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -15),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -15),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 15)
        ]
        toastContainer.addConstraints(labelConstraints)

        // Constraints for toastContainer inside window
        let containerConstraints = [
            toastContainer.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 65),
            toastContainer.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -65),
            toastContainer.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -75)
        ]
        window.addConstraints(containerConstraints)

        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
