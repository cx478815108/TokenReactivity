//
//  People.m
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/11.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import "People.h"

@implementation People

#pragma mark - TokenReactiveProperty
+ (id)tokenReactiveGetterProperty:(TokenSwizzleInfo *)swizzleInfo
                     propertyName:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"testTokenStruct"]) {
        return TOKEN_CUSTOM_GETTER_BLOCK_CONTENT(TokenStruct);
    }
    return nil;
}

+ (id)tokenReactiveSetterProperty:(TokenSwizzleInfo *)swizzleInfo
                     propertyName:(NSString *)propertyName {
    
    if ([propertyName isEqualToString:@"testTokenStruct"]) {
        return TOKEN_CUSTOM_SETTER_BLOCK_CONTENT(TokenStruct,
                                                 [(People *)instance testTokenStruct],
                                                 oldVal.a == newVal.a && oldVal.b == newVal.b);
    }
    return nil;
}

- (void)dealloc {
    NSLog(@"People dead:%@", self);
}
@end
