//
//  TokenReactivityFunctionTests.m
//  TokenReactivityTests
//
//  Created by 陈雄 on 2020/4/12.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TokenReactivity.h"
#import "People.h"
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>

@interface TokenReactivityFunctionTests : XCTestCase

@end

@implementation TokenReactivityFunctionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPropertyChainReactive {
    People *student = [[People alloc] init];
    TokenObserve([People class]);
    __block int testInt = 0;
    __block int excuseCount = 0;
    
    // 开始执行一次 excuseCount = 1
    TokenEffect(^{
        testInt = student.girlfriend.testInt;
        excuseCount +=1;
    });
    
    // 触发effect excuseCount = 2
    student.girlfriend = [[People alloc] init];
    
    // 检查初始值
    assertThatInt(testInt, equalToInt(student.girlfriend.testInt));
    
    // 检查值变化
    // 触发effect excuseCount = 3
    student.girlfriend.testInt = 233;
    assertThatInt(testInt, equalToInt(student.girlfriend.testInt));

    // 值未变化，不应执行block
    student.girlfriend.testInt = 233;
    assertThatInt(excuseCount, equalToInt(3));
}

@end
