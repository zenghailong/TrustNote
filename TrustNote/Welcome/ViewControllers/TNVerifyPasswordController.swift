//
//  TNVerifyPasswordController.swift
//  TrustNote
//
//  Created by zenghailong on 2018/5/10.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TNVerifyPasswordController: TNBaseViewController {
    
    let topPadding = IS_iphone5 ? (88 + kStatusbarH) : (128 + kStatusbarH)
    
    var isDismissAnimated: Bool?
    
    var verifyPasswordView: TNCustomAlertView?
    
    public var passwordAlertView = TNPasswordAlertView.loadViewFromNib()
    
    fileprivate lazy var topView: TNCreateWalletTopView = {
        let topView = TNCreateWalletTopView.loadViewFromNib()
        return topView
    }()
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = kAlertBackgroundColor
    }
    
    private let textLabel = UILabel().then {
        $0.textColor = kThemeTextColor
        $0.font = UIFont.systemFont(ofSize: 16.0)
        $0.text = NSLocalizedString("The wallet has been encrypted", comment: "")
    }
    
    private let continueBtn = TNButton().then {
        $0.setTitle(NSLocalizedString("Click continue", comment: ""), for: .normal)
        $0.setTitleColor(kGlobalColor, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(TNVerifyPasswordController.handleTapGesture))
        view.addGestureRecognizer(tap)
        passwordAlertView.delegate = self
        IQKeyboardManager.shared.enable = false
        distance = 40.0
        isNeedMove = true
    }
}

extension TNVerifyPasswordController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topPadding)
            make.left.right.equalToSuperview()
            make.height.equalTo(190)
        }
        layoutDynamicSubviews()
    }
    
    fileprivate func layoutDynamicSubviews() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        backgroundView.addSubview(passwordAlertView)
        passwordAlertView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(kLeftMargin)
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(kVerifyPasswordAlertHeight)
        }
    }
}

extension TNVerifyPasswordController: TNPasswordAlertViewDelegate {
    
    func passwordVerifyCorrect(_ password: String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if !TNGlobalHelper.shared.encryptePrivKey.isEmpty {
            let xPrivkey = TNGlobalHelper.shared.getPrivkey()
            TNEvaluateScriptManager.sharedInstance.getEcdsaPrivkey(xPrivKey: xPrivkey) {
                TNHubViewModel.loginHub()
            }
            TNEvaluateScriptManager.sharedInstance.generateRootPublicKey(xPrivKey: xPrivkey)
        } else {
            if delegate.isTabBarRootController() && !TNGlobalHelper.shared.tempPrivKey.isEmpty {
                let encPrivKey = AES128CBC_Unit.aes128Encrypt(TNGlobalHelper.shared.tempPrivKey, key: password)
                TNGlobalHelper.shared.encryptePrivKey = encPrivKey!
                TNConfigFileManager.sharedInstance.updateProfile(key: "xPrivKey", value: encPrivKey!)
                TNGlobalHelper.shared.tempPrivKey = ""
            }
        }
        TNGlobalHelper.shared.isVerifyPasswdForMain = false
        self.dismiss(animated: true, completion: nil)
        if delegate.isTabBarRootController() {
            TNGlobalHelper.shared.password = nil
        }
    }
    
    func didClickedCancelButton() {
        self.backgroundView.removeFromSuperview()
    }
    
}

extension TNVerifyPasswordController {
    
    @objc fileprivate func handleTapGesture() {
        layoutDynamicSubviews()
        self.passwordAlertView.passwordTextField.becomeFirstResponder()
    }
}
