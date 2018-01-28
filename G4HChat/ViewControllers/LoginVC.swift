//
//  ViewController.swift
//  G4HChat
//
//  Created by Codegreen on 19/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit
import ToastSwiftFramework

class LoginVC: UIViewController {

    @IBOutlet var loginBtn: UIButton!
    @IBOutlet private var accountTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    private let socket = WebSocketManager.shard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.socket.delegate = self
        self.socket.open()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickLoginBtn(_ sender: Any) {
        self.view.endEditing(true)
        guard self.socket.saidHi else {
            self.view.makeToast("Wait a minute")
            return
        }
        self.view.makeToastActivity(.center)
        let account = self.accountTextField.text!
        let password = self.passwordTextField.text!
        self.socket.login(account: account, password: password)
    }

    @IBAction func editingChange(_ sender: Any) {
        let account = self.accountTextField.text!
        let password = self.passwordTextField.text!
        if account.count > 0 && password.count > 0 {
            self.loginBtn.isEnabled = true
        } else {
            self.loginBtn.isEnabled = false
        }
    }
}

extension LoginVC: WebSocketProtocol {
    func loginResult(user: UserModel?, error: String?) {

        self.view.hideToastActivity()
        guard user != nil else {
            self.noticeAlert(title: "Error", message: error)
            return
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainNavigation")
        self.present(vc!, animated: true, completion: nil)
    }
}
