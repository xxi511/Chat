//
//  ViewControllerEX.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func noticeAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            guard self.navigationController != nil else {return}
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
