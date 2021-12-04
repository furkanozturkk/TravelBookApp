//
//  Helper.swift
//  TravelBookApp
//
//  Created by Furkan Öztürk on 4.12.2021.
//

import UIKit

class Helper: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    static func Alert(title:String,message:String,hasReturn:Bool,over viewController:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        let returnAlertAction = UIAlertAction(title: "Önceki Sayfa", style: UIAlertAction.Style.default) { Action in
            NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
            viewController.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAlertAction)
        if hasReturn {
            alert.addAction(returnAlertAction)
        }
        viewController.present(alert, animated: true, completion: nil)
        
    }

}
