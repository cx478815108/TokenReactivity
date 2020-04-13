//
//  TokenReactivityTests.m
//  TokenReactivityTests
//
//  Created by 陈雄 on 2020/3/10.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TokenReactivity.h"
#import "People.h"
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>

@interface TokenReactivityTests : XCTestCase

@end

@implementation TokenReactivityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testObject {
    TokenObserve([People class]);
    __block People *girlfriend = [[People alloc] init];
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        girlfriend = student.girlfriend;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(girlfriend, equalTo(student.girlfriend));
    
    // 检查值变化
    student.girlfriend = [[People alloc] init];
    assertThat(girlfriend, equalTo(student.girlfriend));

    // 值未变化，不应执行block
    student.girlfriend = student.girlfriend;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testClass {
    TokenObserve([People class]);
    __block Class testClass;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    student.testClass = NSClassFromString(@"People");
    
    TokenEffect(^{
        testClass = student.testClass;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromClass(testClass), equalTo(NSStringFromClass(student.testClass)));
    
    // 检查值变化
    student.testClass = NSClassFromString(@"UIViewController");
    assertThat(NSStringFromClass(testClass), equalTo(NSStringFromClass(student.testClass)));

    // 值未变化，不应执行block
    student.testClass = NSClassFromString(@"UIViewController");
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testLong {
    TokenObserve([People class]);
    __block long testLong =  99999;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testLong = student.testLong;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatLong(testLong, equalToLong(student.testLong));
    
    // 检查值变化
    student.testLong = 99997;
    assertThatLong(testLong, equalToLong(student.testLong));

    // 值未变化，不应执行block
    student.testLong = testLong;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testInt {
    TokenObserve([People class]);
    __block int testInt = 253;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testInt = student.testInt;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatInt(testInt, equalToInt(student.testInt));
    
    // 检查值变化
    student.testInt = 233;
    assertThatInt(testInt, equalToInt(student.testInt));

    // 值未变化，不应执行block
    student.testInt = 233;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testShort {
    TokenObserve([People class]);
    __block short testShort = 253;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testShort = student.testShort;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatShort(testShort, equalToShort(student.testShort));
    
    // 检查值变化
    student.testShort = 233;
    assertThatShort(testShort, equalToShort(student.testShort));

    // 值未变化，不应执行block
    student.testShort = 233;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testDouble {
    TokenObserve([People class]);
    __block double testDouble = 3.1415926;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testDouble = student.testDouble;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatDouble(testDouble, equalToDouble(student.testDouble));
    
    // 检查值变化
    student.testDouble = 3.1415927;
    assertThatDouble(testDouble, equalToDouble(student.testDouble));

    // 值未变化，不应执行block
    student.testDouble = 3.1415927;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testBool {
    TokenObserve([People class]);
    __block bool testBool = true;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testBool = student.testBool;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(@(testBool), equalTo(@(student.testBool)));
    
    // 检查值变化
    student.testBool = true;
    assertThat(@(testBool), equalTo(@(student.testBool)));

    // 值未变化，不应执行block
    student.testBool = true;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testFloat {
    TokenObserve([People class]);
    __block float testFloat = 3.1415;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    TokenEffect(^{
        testFloat = student.testFloat;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatFloat(testFloat, equalToFloat(student.testFloat));
    
    // 检查值变化
    student.testFloat = 3.1415;
    assertThatFloat(testFloat, equalToFloat(student.testFloat));

    // 值未变化，不应执行block
    student.testFloat = 3.1415;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testULong {
    TokenObserve([People class]);
    __block unsigned long testULong = 233;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testULong = student.testULong;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatUnsignedLong(testULong, equalToUnsignedLong(student.testULong));
    
    // 检查值变化
    student.testULong = 99997;
    assertThatUnsignedLong(testULong, equalToUnsignedLong(student.testULong));

    // 值未变化，不应执行block
    student.testULong = testULong;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testUInt {
    TokenObserve([People class]);
    __block unsigned int testUInt = 23;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testUInt = student.testUInt;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatUnsignedInt(testUInt, equalToUnsignedInt(student.testUInt));
    
    // 检查值变化
    student.testUInt = 99997;
    assertThatUnsignedInt(testUInt, equalToUnsignedInt(student.testUInt));

    // 值未变化，不应执行block
    student.testUInt = testUInt;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testUChar {
    TokenObserve([People class]);
    __block unsigned char testUChar = 'a';
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testUChar = student.testUChar;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatUnsignedChar(testUChar, equalToUnsignedChar(student.testUChar));
    
    // 检查值变化
    student.testUChar = 'b';
    assertThatUnsignedChar(testUChar, equalToUnsignedChar(student.testUChar));

    // 值未变化，不应执行block
    student.testUChar = 'b';
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testUShort {
    TokenObserve([People class]);
    __block unsigned short testUShort = 199;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testUShort = student.testUShort;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThatUnsignedShort(testUShort, equalToUnsignedShort(student.testUShort));
    
    // 检查值变化
    student.testUShort = 198;
    assertThatUnsignedShort(testUShort, equalToUnsignedShort(student.testUShort));

    // 值未变化，不应执行block
    student.testUShort = 198;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testCharPointer {
    TokenObserve([People class]);
    __block char *testCharPointer = "";
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    student.testCharPointer = "thanks";
    
    TokenEffect(^{
        testCharPointer = student.testCharPointer;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat([[NSString alloc] initWithUTF8String:testCharPointer], equalTo([[NSString alloc] initWithUTF8String:student.testCharPointer]));
    
    // 检查值变化
    student.testCharPointer = "Sure!";
    assertThat([[NSString alloc] initWithUTF8String:testCharPointer], equalTo([[NSString alloc] initWithUTF8String:student.testCharPointer]));

    // 值未变化，不应执行block
    student.testCharPointer = "Sure!";
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testSEL {
    TokenObserve([People class]);
    __block SEL testSEL;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    student.testSEL = @selector(copy);
    
    TokenEffect(^{
        testSEL = student.testSEL;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromSelector(testSEL), equalTo(NSStringFromSelector(student.testSEL)));
    
    // 检查值变化
    student.testSEL = @selector(copy);
    assertThat(NSStringFromSelector(testSEL), equalTo(NSStringFromSelector(student.testSEL)));

    // 值未变化，不应执行block
    student.testSEL = @selector(mutableCopy);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testSize {
    TokenObserve([People class]);
    __block CGSize testSize;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testSize = student.testSize;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromCGSize(testSize), equalTo(NSStringFromCGSize(student.testSize)));
    
    // 检查值变化
    student.testSize = CGSizeMake(100, 50);
    assertThat(NSStringFromCGSize(testSize), equalTo(NSStringFromCGSize(student.testSize)));

    // 值未变化，不应执行block
    student.testSize = CGSizeMake(100, 50);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testPoint {
    TokenObserve([People class]);
    __block CGPoint testPoint;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testPoint = student.testPoint;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromCGPoint(testPoint), equalTo(NSStringFromCGPoint(student.testPoint)));
    
    // 检查值变化
    student.testPoint = CGPointMake(100, 50);
    assertThat(NSStringFromCGPoint(testPoint), equalTo(NSStringFromCGPoint(student.testPoint)));

    // 值未变化，不应执行block
    student.testPoint = CGPointMake(100, 50);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testRect {
    TokenObserve([People class]);
    __block CGRect testRect;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testRect = student.testRect;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromCGRect(testRect), equalTo(NSStringFromCGRect(student.testRect)));
    
    // 检查值变化
    student.testRect = CGRectMake(0, 0, 100, 100);
    assertThat(NSStringFromCGRect(testRect), equalTo(NSStringFromCGRect(student.testRect)));

    // 值未变化，不应执行block
    student.testRect = CGRectMake(0, 0, 100, 100);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testAffineTransform {
    TokenObserve([People class]);
    __block CGAffineTransform testAffineTransform;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];

    TokenEffect(^{
        testAffineTransform = student.testAffineTransform;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromCGAffineTransform(testAffineTransform), equalTo(NSStringFromCGAffineTransform(student.testAffineTransform)));
    
    // 检查值变化
    student.testAffineTransform = CATransform3DGetAffineTransform(CATransform3DIdentity);
    assertThat(NSStringFromCGAffineTransform(testAffineTransform), equalTo(NSStringFromCGAffineTransform(student.testAffineTransform)));

    // 值未变化，不应执行block
    student.testRect = CGRectMake(100, 50, 233, 49);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testTransform3D {
    TokenObserve([People class]);
    __block CATransform3D testTransform3D;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    student.testTransform3D = CATransform3DIdentity;
    
    TokenEffect(^{
        testTransform3D = student.testTransform3D;
        excuseCount += 1;
    });
    
    // 检查初始值
    assert(CATransform3DEqualToTransform(testTransform3D, student.testTransform3D));
    
    // 检查值变化
    student.testTransform3D = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.5);
    assert(CATransform3DEqualToTransform(testTransform3D, student.testTransform3D));

    // 值未变化，不应执行block
    student.testTransform3D = student.testTransform3D;
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testUIOffset {
    TokenObserve([People class]);
    __block UIOffset testUIOffset;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testUIOffset = student.testUIOffset;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromUIOffset(testUIOffset), equalTo(NSStringFromUIOffset(student.testUIOffset)));
    
    // 检查值变化
    student.testUIOffset = UIOffsetMake(10, 20);
    assertThat(NSStringFromUIOffset(testUIOffset), equalTo(NSStringFromUIOffset(student.testUIOffset)));

    // 值未变化，不应执行block
    student.testUIOffset = UIOffsetMake(10, 20);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testUIEdgeInsets {
    TokenObserve([People class]);
    __block UIEdgeInsets testUIEdgeInsets;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testUIEdgeInsets = student.testUIEdgeInsets;
        excuseCount += 1;
    });
    
    // 检查初始值
    assertThat(NSStringFromUIEdgeInsets(testUIEdgeInsets), equalTo(NSStringFromUIEdgeInsets(student.testUIEdgeInsets)));
    
    // 检查值变化
    student.testUIEdgeInsets = UIEdgeInsetsMake(0, 1, 2, 3);
    assertThat(NSStringFromUIEdgeInsets(testUIEdgeInsets), equalTo(NSStringFromUIEdgeInsets(student.testUIEdgeInsets)));

    // 值未变化，不应执行block
    student.testUIEdgeInsets = UIEdgeInsetsMake(0, 1, 2, 3);
    assertThatInt(excuseCount, equalToInt(2));
}

- (void)testTokenStruct {
    TokenObserve([People class]);
    __block TokenStruct testTokenStruct;
    __block int excuseCount = 0;
    People *student = [[People alloc] init];
    
    TokenEffect(^{
        testTokenStruct = student.testTokenStruct;
        excuseCount += 1;
    });
    
    // 检查初始值
    if (testTokenStruct.a == student.testTokenStruct.a && testTokenStruct.b == testTokenStruct.b) {
        assert(1);
    } else {
        assert(0);
    }
    
    // 检查值变化
    student.testTokenStruct = (TokenStruct){1.0, 3.2};
    if (testTokenStruct.a == student.testTokenStruct.a && testTokenStruct.b == testTokenStruct.b) {
        assert(1);
    } else {
        assert(0);
    }

    // 值未变化，不应执行block
    student.testTokenStruct = (TokenStruct){1.0, 3.2};
    assertThatInt(excuseCount, equalToInt(2));
}

@end
