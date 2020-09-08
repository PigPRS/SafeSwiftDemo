//
//  CheckPhoneEnvironment.swift
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

import UIKit

class CheckPhoneEnvironment: NSObject {

    class func isJailbroken() -> Bool {
        // 检查是否存在越狱常用文件
        let jailFilePaths = ["/Applications/Cydia.app",
                             "/Library/MobileSubstrate/MobileSubstrate.dylib",
//                             "/bin/bash",
//                             "/usr/sbin/sshd",
                             "/etc/apt"]
        for filePath in jailFilePaths {
            if FileManager.default.fileExists(atPath: filePath) {
                return true
            }
        }
        
        // 检查是否安装了越狱工具Cydia
        if UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
            return true
        }
        
        // 检查是否有权限读取系统应用列表
        if FileManager.default.fileExists(atPath: "/User/Applications/") {
            if let applist = try? FileManager.default.contentsOfDirectory(atPath: "/User/Applications/") {
                debugPrint(applist)
                return true
            }
        }
        
        // 检测当前程序运行的环境变量
        let env = getenv("DYLD_INSERT_LIBRARIES")
        if env != nil {
            return true
        }
        
        return false
    }
    
}
