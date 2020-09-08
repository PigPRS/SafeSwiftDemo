//
//  ViewController2.m
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)test {
//    ViewController1 *vc =  [ViewController1 new];
//    [vc viewControllerTestMethodA];
//    [vc viewControllerTestMethodA1];
    
    //字符串加密
    NSString *ocStr = /*@"return c string"*/AMDecodeOCString(&BHJSafeEncodedOCKey);
    char *cStr = /*@"local char str"*/AMDecodeCString(&BHJSafeEncodedCKey);
    NSLog(@"%@",ocStr);
    NSLog(@"%s",cStr);
    
}

@end
