//
//  TokenObserve.h
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/15.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenReactiveEffect.h"
#import "TokenSwizzle.h"

NS_ASSUME_NONNULL_BEGIN

@class TokenSwizzleInfo;

/*
 获取是否正在依赖收集过程中
*/
extern BOOL TokenIsEffectTracking(void);

/*
 观察
*/
extern void TokenObserve(Class instanceCls);

/*
 对当前对象的propertyName的属性进行依赖收集
 @param instance 当前对象
 @param propertyName 属性name
*/
extern void TokenReactiveTrack(NSObject *instance, NSString *propertyName);

/*
 触发一次effect回调
 @param instance 当前对象
 @param propertyName 属性name
*/
extern void TokenReactiveTrigger(NSObject *instacnce, NSString *propertyName);

/*
 生成一个副作用对象
 当观察对象的值改变后，会产生某些影响，称之为副作用
 ⚠️:每次观察对象的某个属性改变后，均要回调此block，因此该block 会被持有，
    同时block 内部捕获的变量也不会被释放，应当在block
    内部捕获weak 对象
 @param fn 当观察对象的值改变后回调的block
 */
extern __unused TokenReactiveEffect *TokenEffect(dispatch_block_t fn);

NS_ASSUME_NONNULL_END
