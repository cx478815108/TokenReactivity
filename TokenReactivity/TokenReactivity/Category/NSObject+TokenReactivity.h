//
//  NSObject+TokenReactivity.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/14.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TokenReactiveEffect;
@interface NSObject (TokenReactivity)

+ (BOOL)token_classRespondsToSelector:(SEL)aSelector;

- (void)token_addEffect:(TokenReactiveEffect *)effect
           propertyName:(NSString *)propertyName;

- (NSSet <TokenReactiveEffect *> *)token_getEffectsWithPropertyName:(NSString *)propertyName;
@end

NS_ASSUME_NONNULL_END
