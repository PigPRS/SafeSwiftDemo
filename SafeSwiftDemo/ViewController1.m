//
//  ViewController1.m
//  SafeSwiftDemo
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewControllerTestMethodA1 {
    [self viewControllerTestMethodA];
}

- (void)viewControllerTestMethodA {
    NSLog(@"111");
}

@end
