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
        IDFALabel.text = DeviceHelper.IDFA
        IDFVLabel.text = DeviceHelper.IDFV
        
        if !DeviceHelper.isATTSupported {
            IDFAStatusContainerView.removeFromSuperview()
        } else {
            ATTStatusLabel.text = DeviceHelper.ATTStatusString
            ATTStatusLabel.textColor = DeviceHelper.isATTAccepted ? .init(named: "main-green") : .init(named: "main-red")
        }
        
        iOSVersionLabel.text = DeviceHelper.Device.osVersion
        connectionTypeLabel.text = DeviceHelper.Device.connectionType()
        countryLabel.text = DeviceHelper.Device.country
        languageLabel.text = DeviceHelper.Device.language
        timezoneLabel.text = DeviceHelper.Device.timezone
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
