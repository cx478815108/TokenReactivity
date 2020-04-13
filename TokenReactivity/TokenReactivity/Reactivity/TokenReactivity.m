//
//  TokenObserve.m
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/15.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import "TokenReactivity.h"
#import "TokenSwizzle.h"
#import "TokenImpBlockFactory.h"
#import "NSObject+TokenReactivity.h"
#import "TokenReactivePropertyProtocol.h"
#import <objc/message.h>
#import <objc/runtime.h>

typedef struct TokenReactiveInfo {
    BOOL isTracking;
} TokenReactiveInfo;

static TokenReactiveInfo TokenReactiveGlobalInfo = { NO };

#pragma mark - Storage
inline static NSMutableArray *TokenEffectStack() {
    static NSMutableArray *stack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stack = @[].mutableCopy;
    });
    return stack;
}

inline static NSMutableDictionary *TokenHookedClasses() {
    static NSMutableDictionary *classes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = @{}.mutableCopy;
    });
    return classes;
}

#pragma mark - State
inline BOOL TokenIsEffectTracking(void) {
    return TokenReactiveGlobalInfo.isTracking;
}

inline static void TokenEffectCommitTracking(dispatch_block_t action) {
    if (action) {
        TokenReactiveGlobalInfo.isTracking = YES;
        action();
        TokenReactiveGlobalInfo.isTracking = NO;
    }
}

inline static BOOL TokenCanObserveClass(Class cls) {
    static NSDictionary *invalidClasses;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        invalidClasses = @{
            @"__NSCFConstantString"  : @(YES),
            @"NSTaggedPointerString" : @(YES),
            @"__NSCFNumber"          : @(YES),
            @"__NSCFString"          : @(YES)
        };
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSDictionary *map = invalidClasses.copy;
    dispatch_semaphore_signal(lock);
    
    return map[NSStringFromClass(cls)] == nil;
}

inline static BOOL TokenIsClassDidHook(Class cls) {
    
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSDictionary *clsMap = TokenHookedClasses().copy;
    dispatch_semaphore_signal(lock);
    
    if (cls && clsMap[NSStringFromClass(cls)]) {
        return YES;
    }
    return NO;
}

inline static void TokenSetClassHooked(Class cls) {
    if (cls) {
        TokenHookedClasses()[NSStringFromClass(cls)] = @(YES);
    }
}

inline static BOOL TokenIsObjcPropertyReadonly(objc_property_t property) {
    const char *attrs = property_getAttributes(property);
    for (int i = 0; i < strlen(attrs); i++) {
        const char c = attrs[i];
        if (c == ',') {
            const char next = attrs[i+1];
            if (next == 'R') {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

inline static BOOL TokenIsObjcPropertyTypeObject(objc_property_t property) {
    const char *attrs = property_getAttributes(property);
    return attrs[1] == '@';
}

#pragma mark - Object Hook
inline static NSString *TokenSetterForGetter(NSString *getter)
{
    if (getter.length <= 0) {
        return nil;
    }

    NSString *firstLetter      = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [getter substringFromIndex:1];
    NSString *setter           = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];
    return setter;
}

inline static void TokenGetObjcectPropertyNames(Class targetCls,
                                                NSArray **readonlyProperties,
                                                NSArray **readwriteProperties) {
    NSMutableArray *readonlys  = @[].mutableCopy;
    NSMutableArray *readwrites = @[].mutableCopy;
    Class cls     = targetCls;
    Class baseCls = [NSObject class];
    while (cls) {
        if (cls != baseCls) {
            unsigned int count = 0;
            objc_property_t *properties = class_copyPropertyList(cls, &count);
            for (NSUInteger i = 0; i < count; i ++) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                // 判断是否是readonly, readonly 不应该hook setter
                if (TokenIsObjcPropertyReadonly(property)) {
                    /*
                     都已经是readonly了，不能更改，但是如果该属性是对象，应该hook getter
                     原因是为了能多层响应 eg:a.b.c
                     */
                    if (TokenIsObjcPropertyTypeObject(property)) {
                        [readonlys addObject:propertyName];
                    }
                } else {
                    [readwrites addObject:propertyName];
                }
            }
            free(properties);
            cls = [cls superclass];
        } else {
            break;
        }
    }
    *readonlyProperties = readonlys.copy;
    *readwriteProperties = readwrites.copy;
}

inline static void TokenHookClassReadonlyProperties(Class cls, NSArray *properties) {
    for (NSString *propertyName in properties) {
        BOOL hookResult = TokenSwizzle(cls,
                                       NSSelectorFromString(propertyName),
                                       ^id (TokenSwizzleInfo *swizzleInfo) {
            return TokenGetterImpBlockFactory(swizzleInfo, propertyName);
        });
        
        if (!hookResult &&
            [cls token_classRespondsToSelector:@selector(tokenReactiveGetterProperty:propertyName:)]) {
            // 自定义的getter 返回
            TokenSwizzle(cls, NSSelectorFromString(propertyName),
                         ^id (TokenSwizzleInfo *swizzleInfo) {
                return [cls tokenReactiveGetterProperty:swizzleInfo propertyName:propertyName];
            });
        }
    }
}

inline static void TokenHookClassReadwriteProperties(Class cls, NSArray *properties) {
    for (NSString *propertyName in properties) {
        NSString *getterName = propertyName;
        __block const char *valueType = "";
        // hook getter
        BOOL hookResult = TokenSwizzle(cls,
                                       NSSelectorFromString(getterName),
                                       ^id (TokenSwizzleInfo *swizzleInfo) {
            valueType = swizzleInfo.methodSignature.methodReturnType;
            return TokenGetterImpBlockFactory(swizzleInfo, propertyName);
        });
        
        if (!hookResult &&
            [cls token_classRespondsToSelector:@selector(tokenReactiveGetterProperty:propertyName:)]) {
            // 自定义的getter 返回
            TokenSwizzle(cls, NSSelectorFromString(getterName),
                                           ^id (TokenSwizzleInfo *swizzleInfo) {
                return [cls tokenReactiveGetterProperty:swizzleInfo propertyName:propertyName];
            });
        }
        
        // hook setter
        NSString *setterName = TokenSetterForGetter(getterName);
        hookResult = TokenSwizzle(cls,
                                  NSSelectorFromString(setterName),
                                  ^id (TokenSwizzleInfo *swizzleInfo) {
            return TokenSetterImpBlockFactory(swizzleInfo,
                                              propertyName,
                                              valueType);
        });
        
        if (!hookResult &&
            [cls token_classRespondsToSelector:@selector(tokenReactiveSetterProperty:propertyName:)]) {
            // 自定义的setter 返回
            TokenSwizzle(cls, NSSelectorFromString(setterName),
                         ^id (TokenSwizzleInfo *swizzleInfo) {
                return [cls tokenReactiveSetterProperty:swizzleInfo
                                                             propertyName:propertyName];
            });
        }
    }
}

inline void TokenObserve(Class instanceCls) {
    if (!TokenCanObserveClass(instanceCls) ||
        TokenIsClassDidHook(instanceCls)) {
        return;
    }
    // 设置已经被hook 了 必须在真实hook 之前
    TokenSetClassHooked(instanceCls);
   
    NSArray *readonlyProperties  = nil;
    NSArray *readwriteProperties = nil;
    
    // 获取实例的属性准备hook
    TokenGetObjcectPropertyNames(instanceCls, &readonlyProperties, &readwriteProperties);
    // hook readonlyProperties
    TokenHookClassReadonlyProperties(instanceCls, readonlyProperties);
    // hook readwriteProperties
    TokenHookClassReadwriteProperties(instanceCls, readwriteProperties);
}

#pragma mark - Reactive implementation
inline void TokenReactiveTrack(NSObject *instance, NSString *propertyName) {
    TokenReactiveEffect *effect = [TokenEffectStack() lastObject];
    if (!effect) {
        return;
    }
    
    // keep effect alive
    [instance token_addEffect:effect propertyName:propertyName];
}

inline static void TokenReactiveRun(TokenReactiveEffect *effect) {
    if (effect.rawFn) {
        // 防止依赖收集过程中，触发了setter，导致无限递归
        NSMutableArray *stack = TokenEffectStack();
        if (![stack containsObject:effect]) {
            [stack addObject:effect];
            TokenEffectCommitTracking(effect.rawFn);
            [stack removeLastObject];
        }
    }
}

inline void TokenReactiveTrigger(NSObject *instacnce, NSString *propertyName) {
    NSSet *deps = [instacnce token_getEffectsWithPropertyName:propertyName];
    for (TokenReactiveEffect *effect in deps) {
        TokenReactiveRun(effect);
    }
}

__unused TokenReactiveEffect *TokenEffect(_Nonnull dispatch_block_t fn) {
    
    TokenReactiveEffect *effect = [[TokenReactiveEffect alloc] init];
    effect.rawFn = fn;
    __weak TokenReactiveEffect *weakEffect = effect;
    effect.effectRunner = ^() {
        __strong TokenReactiveEffect *strongEffect = weakEffect;
        return TokenReactiveRun(strongEffect);
    };
    
    // 主动触发一次依赖收集
    effect.effectRunner();
    return effect;
}
