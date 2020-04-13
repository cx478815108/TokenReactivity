//
//  TokenNewImplementationBlockFactory.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/20.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@import UIKit;
@class TokenSwizzleInfo;

extern id TokenGetterImpBlockFactory(TokenSwizzleInfo *swizzleInfo, NSString *propertyName);

extern id TokenSetterImpBlockFactory(TokenSwizzleInfo *swizzleInfo,
                                     NSString *propertyName,
                                     const char *valueType);

NS_ASSUME_NONNULL_END
