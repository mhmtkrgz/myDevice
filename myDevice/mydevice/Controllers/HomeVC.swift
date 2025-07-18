//
//  HomeVC.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 14.10.2021.
//

import UIKit
import AppTrackingTransparency

final class HomeVC: BaseVC {
    @IBOutlet weak var IDFALabel: UILabel!
    @IBOutlet weak var IDFVLabel: UILabel!
    
    @IBOutlet weak var IDFAStatusContainerView: UIView!
    @IBOutlet weak var ATTStatusLabel: UILabel!
    
    @IBOutlet weak var iOSVersionLabel: UILabel!
    @IBOutlet weak var connectionTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var timezoneLabel: UILabel!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupData), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: Setup
    @objc func setupData() {
        DispatchQueue.main.async {
            self.IDFALabel.text = DeviceHelper.IDFA
            self.IDFVLabel.text = DeviceHelper.IDFV
            
            if !DeviceHelper.isATTSupported {
                self.IDFAStatusContainerView.removeFromSuperview()
            } else {
                self.ATTStatusLabel.text = DeviceHelper.ATTStatusString
                self.ATTStatusLabel.textColor = DeviceHelper.isATTAccepted ? .init(named: "main-green") : .init(named: "main-red")
            }
            
            self.iOSVersionLabel.text = DeviceHelper.Device.osVersion
            self.connectionTypeLabel.text = DeviceHelper.Device.connectionType()
            self.countryLabel.text = DeviceHelper.Device.country
            self.languageLabel.text = DeviceHelper.Device.language
            self.timezoneLabel.text = DeviceHelper.Device.timezone
        }
        
    }
    
    // MARK: - Actions
    @IBAction func IDFATapped(_ sender: Any) {
        copyText(text: IDFALabel.text)
    }
    
    @IBAction func IDFVTapped(_ sender: Any) {
        copyText(text: IDFVLabel.text)
    }
    
    @IBAction func ATTStatusTapped(_ sender: Any) {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                return
            } else if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { status in
                    self.setupData()
                }
                return
            }
        }
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
    }
    
    // MARK: - Utils
    private func copyText(text: String?) {
        guard let text = text else { return }
        
        UIPasteboard.general.string = text
        self.view.showToast(.success, message: text)
    }
}
