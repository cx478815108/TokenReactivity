//
//  NSObject+TokenReactivity.m
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/14.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import "NSObject+TokenReactivity.h"
#import <objc/runtime.h>

typedef NSMutableDictionary <NSString *, NSMutableSet <TokenReactiveEffect *> *> *TokenEffectTargetMap;

@implementation NSObject (TokenReactivity)

+ (BOOL)token_classRespondsToSelector:(SEL)aSelector {
    return class_getClassMethod(self, aSelector) != nil;
}

- (dispatch_semaphore_t)token_lock {
    dispatch_semaphore_t lock = objc_getAssociatedObject(self, _cmd);
    if (lock == nil) {
        lock = dispatch_semaphore_create(1);
        objc_setAssociatedObject(self, @selector(token_lock), lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return lock;
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (TokenEffectTargetMap)token_effectMap
{
    TokenEffectTargetMap token_effectMap = objc_getAssociatedObject(self, _cmd);
    if (token_effectMap == nil) {
        token_effectMap = @{}.mutableCopy;
        objc_setAssociatedObject(self, @selector(token_effectMap), token_effectMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return token_effectMap;
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (void)token_addEffect:(TokenReactiveEffect *)effect
           propertyName:(NSString *)propertyName{
    if (effect && propertyName.length) {
        dispatch_semaphore_wait([self token_lock], DISPATCH_TIME_FOREVER);
        
        TokenEffectTargetMap effectMap = [self token_effectMap];
        // 根据properyName 取依赖
        NSMutableSet *deps = effectMap[propertyName];
        if (!deps) {
           deps = [NSMutableSet set];
           effectMap[propertyName] = deps;
        }

        // 判断是否存在effect
        if (![deps containsObject:effect]) {
           [deps addObject:effect];
        }
        
        dispatch_semaphore_signal([self token_lock]);
    }
}

- (NSSet <TokenReactiveEffect *> *)token_getEffectsWithPropertyName:(NSString *)propertyName {
    dispatch_semaphore_wait([self token_lock], DISPATCH_TIME_FOREVER);
    NSMutableSet *deps = [self token_effectMap][propertyName];
    dispatch_semaphore_signal([self token_lock]);
    return deps.copy;
}
@end
