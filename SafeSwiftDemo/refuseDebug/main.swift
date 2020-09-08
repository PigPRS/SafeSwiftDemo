//
//  main.swift
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/18.
//  Copyright © 2020 bhj. All rights reserved.
//

import Foundation
import UIKit

autoreleasepool {
    #if !DEBUG
    disable_gdb()
    #endif
    _ = UIApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
        nil,
        NSStringFromClass(AppDelegate.self)
    )
}
