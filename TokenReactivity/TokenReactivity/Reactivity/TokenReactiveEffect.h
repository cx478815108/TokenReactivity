//
//  TokenReactiveEffect.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/14.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenReactiveEffect : NSObject
@property (nonatomic, copy) dispatch_block_t rawFn;
@property (nonatomic, copy) dispatch_block_t effectRunner;
@end

NS_ASSUME_NONNULL_END
