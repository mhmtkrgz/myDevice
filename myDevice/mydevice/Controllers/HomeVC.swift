//
//  HomeVC.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 14.10.2021.
//

import UIKit

final class HomeVC: BaseVC {
    @IBOutlet weak var IDFALabel: UILabel!
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // MARK: - Actions
    @IBAction func IDFATapped(_ sender: Any) {
        copyText(text: IDFALabel.text)
    }
    
    // MARK: - Utils
    
    private func copyText(text: String?) {
        guard let text = text else { return }
        
        UIPasteboard.general.string = text
        self.view.showToast(.success, message: text)
    }
}
