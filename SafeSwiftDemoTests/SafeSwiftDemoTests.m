//
//  SafeSwiftDemoTests.m
//  SafeSwiftDemoTests
//
//  Created by bhj on 2020/5/19.
//  Copyright © 2020 bhj. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SafeSwiftDemoTests : XCTestCase

@end

@implementation SafeSwiftDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetHexString{
    int seed = 0x64;
    NSString *string = @"local char str";
//    int seed = 0xD7;
//    NSString *string = @"return c string";
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSMutableString *hexStr = [NSMutableString string];
    for (int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",(bytes[i] & 0xff) ^ seed];///16进制数
        [hexStr appendString:[self formateHexString:newHexStr]];
    }
    [hexStr appendString:[self formateHexString:[NSString stringWithFormat:@"%x",seed]]];
    [hexStr deleteCharactersInRange:NSMakeRange(0, 1)];
    NSLog(@"\n%@",hexStr);
}

- (NSString *)formateHexString:(NSString *)hexStr {
    NSString *newHexStr = [hexStr uppercaseString];
    if ([newHexStr length] == 1) {
        return [NSString stringWithFormat:@", 0x0%@",newHexStr];
    } else {
        return [NSString stringWithFormat:@", 0x%@",newHexStr];
    }
}

@end
