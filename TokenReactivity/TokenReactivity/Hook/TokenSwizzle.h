//
//  TokenHook.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/10.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TokenSwizzleInfo;
typedef void (*TokenSwizzleOriginalIMP)(void /* id, SEL, ... */ );
typedef id _Nonnull (^TokenSwizzleImpFactoryBlock)(TokenSwizzleInfo *swizzleInfo);

@interface TokenSwizzleInfo : NSObject
@property (nonatomic, readonly) NSMethodSignature *methodSignature;
@property (nonatomic, readonly) SEL selector;
- (TokenSwizzleOriginalIMP)getOriginalImplementation;
@end

#pragma mark - Public API
extern BOOL TokenSwizzle(Class classToSwizzle,
                         SEL selector,
                         TokenSwizzleImpFactoryBlock factoryBlock);

NS_ASSUME_NONNULL_END
