//
//  RefuseDebug.swift
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/18.
//  Copyright © 2020 bhj. All rights reserved.
//

import UIKit

public class RefuseDebug: NSObject {
    /// sysctl:
    /// 当一个进程被调试的时候，该进程会有一个标记来标记自己正在被调试，所以可以通过sysctl去查看当前进程的信息，看有没有这个标记位即可检查当前调试状态。
    /// - Returns: 是否正在调试
    class func isDebugger() -> Bool {
        var name = [Int32]()
        name.append(CTL_KERN)
        name.append(KERN_PROC)
        name.append(KERN_PROC_PID)
        name.append(getpid())

        var info = kinfo_proc()
        info.kp_proc.p_flag = 0
        var infoSize = MemoryLayout.size(ofValue: info) as size_t
        if sysctl(&name, 4, &info, &infoSize, nil, 0) == -1 {
            return false
        }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
}
