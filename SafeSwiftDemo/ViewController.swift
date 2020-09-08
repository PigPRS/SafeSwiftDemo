//
//  ViewController.swift
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        
//        let vc = ViewController1()
//        vc.perform(#selector(ViewController1.viewControllerTestMethodA1))
//
        let vc = ViewController2()
        vc.test()
        
        viewControllerTestMethodA2()
    }


    @objc func buttonAction() {
        let alert = UIAlertController(title: "弹框", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "a", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    public func viewControllerTestMethodA2() {
        print("viewControllerTestMethodA2")
        
        if RefuseDebug.isDebugger() {
            exit(0)
        }
        
        let hashDic = CheckFileMD5Hash.getFileHash(withPath: Bundle.main.resourcePath ?? "")
        print(hashDic)
        
        let isJailbroken = CheckPhoneEnvironment.isJailbroken()
        print(isJailbroken)

    }
    
}

