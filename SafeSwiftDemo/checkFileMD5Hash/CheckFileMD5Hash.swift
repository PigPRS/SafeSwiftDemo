//
//  CheckFileMD5Hash.swift
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

import Foundation

public class CheckFileMD5Hash: NSObject {
    
    /// 获取指定路径下不是目录的所有文件的MD5Hash
    class func getFileHash(withPath: String) -> [String: String] {
        var dicHash: [String: String] = [:]
        let fileArr = self.getAllFiles(atPath: withPath)
        for fileName in fileArr {
            let hashString = FileHash.md5HashOfFile(atPath: Bundle.main.resourcePath?.appending("/\(fileName)"))
            if let hashString = hashString {
                dicHash[fileName] = hashString
            }
        }
        return dicHash
    }
    
    /// 获取指定路径下不是目录的所有文件
    class func getAllFiles(atPath: String) -> [String] {
        var fileArr: [String] = []
        let manager = FileManager.default
        let tempFileArr = try? manager.contentsOfDirectory(atPath: atPath)
        if let tempFileArr = tempFileArr {
            for fileName in tempFileArr {
                var flag: ObjCBool = false
                let fullpath = atPath.appending("/\(fileName)")
                if manager.fileExists(atPath: fullpath, isDirectory: &flag) {
                    if !flag.boolValue {
                        fileArr.append(fileName)
                    }
                }
                
            }
        }
        return fileArr
    }
    
}
