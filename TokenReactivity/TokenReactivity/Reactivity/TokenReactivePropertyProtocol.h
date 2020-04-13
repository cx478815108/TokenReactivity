//
//  TokenReactivityProperty.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/4/12.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenReactivity.h"

#define TOKEN_CUSTOM_GETTER_BLOCK_CONTENT(TYPE) \
^TokenStruct (NSObject * _Nonnull instance) {\
    TYPE (*originalIMP)(__unsafe_unretained id, SEL);\
    originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];\
    TYPE origin = originalIMP(instance, swizzleInfo.selector);\
    if (TokenIsEffectTracking()) {\
        TokenReactiveTrack(instance, propertyName);\
    }\
    return origin;\
};

#define TOKEN_CUSTOM_SETTER_BLOCK_CONTENT(TYPE, OLDVALUECODE, COMPARECODE) \
^void (NSObject * _Nonnull instance, TYPE newVal) {\
    TYPE oldVal = OLDVALUECODE;\
    void (*originalIMP)(__unsafe_unretained id, SEL, TYPE);\
    originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];\
    originalIMP(instance, swizzleInfo.selector, newVal);\
    BOOL change = COMPARECODE;\
    if (!change) {\
        TokenReactiveTrigger(instance, propertyName);\
    }\
};

NS_ASSUME_NONNULL_BEGIN

@protocol TokenReactiveProperty <NSObject>
@optional
+ (id)tokenReactiveGetterProperty:(TokenSwizzleInfo *)swizzleInfo
                     propertyName:(NSString *)propertyName;

+ (id)tokenReactiveSetterProperty:(TokenSwizzleInfo *)swizzleInfo
                     propertyName:(NSString *)propertyName;
@end

NS_ASSUME_NONNULL_END
