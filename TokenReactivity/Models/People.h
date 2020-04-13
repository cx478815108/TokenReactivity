//
//  People.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/11.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenReactivePropertyProtocol.h"

@import UIKit;
NS_ASSUME_NONNULL_BEGIN

typedef struct TokenStruct {
    float a;
    float b;
} TokenStruct;

@interface People : NSObject <TokenReactiveProperty>
@property (nonatomic, strong) People *girlfriend;
@property (nonatomic, assign) Class testClass;
@property (nonatomic, assign) float testFloat;
@property (nonatomic, assign) char *testCharPointer;
@property (nonatomic, assign) long testLong;
@property (nonatomic, assign) char testChar;
@property (nonatomic, assign) bool testBool;
@property (nonatomic, assign) int testInt;
@property (nonatomic, assign) short testShort;
@property (nonatomic, assign) double testDouble;
@property (nonatomic, assign) unsigned char testUChar;
@property (nonatomic, assign) unsigned int testUInt;
@property (nonatomic, assign) unsigned short testUShort;
@property (nonatomic, assign) unsigned long testULong;
@property (nonatomic, assign) SEL testSEL;
@property (nonatomic, assign) CGSize testSize;
@property (nonatomic, assign) CGRect testRect;
@property (nonatomic, assign) CGPoint testPoint;
@property (nonatomic, assign) CGAffineTransform testAffineTransform;
@property (nonatomic, assign) CATransform3D testTransform3D;
@property (nonatomic, assign) UIOffset testUIOffset;
@property (nonatomic, assign) UIEdgeInsets testUIEdgeInsets;
@property (nonatomic, assign) TokenStruct testTokenStruct;
@end

NS_ASSUME_NONNULL_END
