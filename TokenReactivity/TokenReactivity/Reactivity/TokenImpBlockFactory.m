//
//  TokenNewImplementationBlockFactory.m
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/20.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import "TokenImpBlockFactory.h"
#import "TokenSwizzle.h"
#import "TokenReactivity.h"
#import "NSObject+TokenReactivity.h"
#import <objc/message.h>
#import <objc/runtime.h>

#pragma mark - getter marco

#define TOKEN_BLOCK_FUNC_DECLARE(NAME, TYPE) \
static inline id TokenGetterBlockTypeOf##NAME(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {\
    return ^__typeof(TYPE) (NSObject * _Nonnull instance) {\
        TYPE (*originalIMP)(__unsafe_unretained id, SEL);\
        originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];\
        TYPE origin = originalIMP(instance, swizzleInfo.selector);\
        if (TokenIsEffectTracking()) {\
            TokenReactiveTrack(instance, propertyName);\
        }\
        return origin;\
    };\
}\

#pragma mark - setter marco

#define TOKEN_SETTER_BLOCK_IMP_CALL(TYPE)\
void (*originalIMP)(__unsafe_unretained id, SEL, TYPE);\
originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];\
originalIMP(instance, swizzleInfo.selector, newVal);\

#define TOKEN_SETTER_BLOCK_COMPARE(COMPARECODE)\
BOOL change = {COMPARECODE};\
if (!change) {\
    oldVal = newVal;\
    TokenReactiveTrigger(instance, propertyName);\
}\

#define TOKEN_SETTER_BLOCK_FUNCTION_INVOKE(TYPE ,COMPARECODE)\
TOKEN_SETTER_BLOCK_IMP_CALL(TYPE)\
TOKEN_SETTER_BLOCK_COMPARE(COMPARECODE)

#define TOKEN_SETTER_BLOCK_TYPE_IMP(TYPE)\
^void (NSObject * _Nonnull instance, TYPE newVal) {\
    TYPE oldVal = ((TYPE (*)(id, SEL))objc_msgSend)(instance, NSSelectorFromString(propertyName));\
    TOKEN_SETTER_BLOCK_IMP_CALL(TYPE)\
    TOKEN_SETTER_BLOCK_COMPARE(oldVal == newVal)\
};

#define TOKEN_SETTER_BLOCK_FUNC_DECLARE_IMP(NAME, TYPE, CODE)\
static inline id TokenSetterBlockTypeOf##NAME(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {\
    return ^void (NSObject * _Nonnull instance, TYPE newVal) {\
        CODE\
    };\
}\

#define TOKEN_SETTER_BLOCK_FUNC_STRUCT_DECLEAR_IMPLEMETATION(NAME, TYPE, COMPARECODE) \
TOKEN_SETTER_BLOCK_FUNC_DECLARE_IMP(NAME, TYPE, {\
    TYPE oldVal = ((TYPE (*)(id, SEL))objc_msgSend)(instance, NSSelectorFromString(propertyName));\
    TOKEN_SETTER_BLOCK_FUNCTION_INVOKE(TYPE, COMPARECODE)\
})

#define TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(NAME, TYPE) \
static inline id TokenSetterBlockTypeOf##NAME(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {\
    return TOKEN_SETTER_BLOCK_TYPE_IMP(TYPE);\
}

#define TOKEN_SETTER_BLOCK_FUNCTION_BIG_STRUCT_IMP(NAME, TYPE, GETTERCODE ,COMPARECODE) \
TOKEN_SETTER_BLOCK_FUNC_DECLARE_IMP(NAME, TYPE, {\
    NSValue *value = [instance valueForKeyPath:propertyName];\
    TYPE oldVal = GETTERCODE; \
    TOKEN_SETTER_BLOCK_FUNCTION_INVOKE(TYPE, COMPARECODE)\
})

#define TOKEN_TYPE_VALUE_KEY(TYPE) [[NSString alloc] initWithUTF8String:@encode(TYPE)]
#define TOKEN_GETTER_BLOCK_VALUE(NAME) [NSValue valueWithPointer:TokenGetterBlockTypeOf##NAME]
#define TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(NAME, TYPE) TOKEN_TYPE_VALUE_KEY(TYPE) : TOKEN_GETTER_BLOCK_VALUE(NAME)

#define TOKEN_SETTER_BLOCK_VALUE(NAME) [NSValue valueWithPointer:TokenSetterBlockTypeOf##NAME]
#define TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(NAME, TYPE) TOKEN_TYPE_VALUE_KEY(TYPE) : TOKEN_SETTER_BLOCK_VALUE(NAME)

#pragma mark - getter
#pragma mark - base type
TOKEN_BLOCK_FUNC_DECLARE(Long, long);
TOKEN_BLOCK_FUNC_DECLARE(Char, char);
TOKEN_BLOCK_FUNC_DECLARE(Int, int);
TOKEN_BLOCK_FUNC_DECLARE(Short, short);
TOKEN_BLOCK_FUNC_DECLARE(UnsignedChar, unsigned char);
TOKEN_BLOCK_FUNC_DECLARE(UnsignedInt, unsigned int);
TOKEN_BLOCK_FUNC_DECLARE(UnsignedShort, unsigned short);
TOKEN_BLOCK_FUNC_DECLARE(UnsignedLong, unsigned long);
TOKEN_BLOCK_FUNC_DECLARE(Double, double);
TOKEN_BLOCK_FUNC_DECLARE(Bool, bool);
TOKEN_BLOCK_FUNC_DECLARE(Float, float);
TOKEN_BLOCK_FUNC_DECLARE(Sel, SEL);
TOKEN_BLOCK_FUNC_DECLARE(CString, char *);
TOKEN_BLOCK_FUNC_DECLARE(Class, Class);

#pragma mark - struct
TOKEN_BLOCK_FUNC_DECLARE(UIOffset, UIOffset);
TOKEN_BLOCK_FUNC_DECLARE(UIEdgeInsets, UIEdgeInsets);
TOKEN_BLOCK_FUNC_DECLARE(CGSize, CGSize);
TOKEN_BLOCK_FUNC_DECLARE(CGRect, CGRect);
TOKEN_BLOCK_FUNC_DECLARE(CGPoint, CGPoint);
TOKEN_BLOCK_FUNC_DECLARE(CGAffineTransform, CGAffineTransform);
TOKEN_BLOCK_FUNC_DECLARE(CATransform3D, CATransform3D);

#pragma mark - setter c method
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Long, long)
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Char, char);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Int, int);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Short, short);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(UnsignedChar, unsigned char);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(UnsignedInt, unsigned int);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(UnsignedShort, unsigned short);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(UnsignedLong, unsigned long);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Double, double);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Bool, bool);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Float, float);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Class, Class);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(Sel, SEL);
TOKEN_SETTER_BLOCK_FUNCTION_DECLARE_IMPLEMETATION(CString, char *);
TOKEN_SETTER_BLOCK_FUNC_STRUCT_DECLEAR_IMPLEMETATION(UIOffset, UIOffset, UIOffsetEqualToOffset(oldVal, newVal));
TOKEN_SETTER_BLOCK_FUNC_STRUCT_DECLEAR_IMPLEMETATION(CGSize, CGSize, CGSizeEqualToSize(oldVal, newVal));
TOKEN_SETTER_BLOCK_FUNC_STRUCT_DECLEAR_IMPLEMETATION(CGPoint, CGPoint, CGPointEqualToPoint(oldVal, newVal));

/*
 当返回的结构体大于16 Byte 时 无法直接用runtime 拿到
 因为invoke 的参数列表会发生变化：第一个参数不再是 Block 对象自己，这里不打算复杂的处理
 */
TOKEN_SETTER_BLOCK_FUNCTION_BIG_STRUCT_IMP(UIEdgeInsets,
                                              UIEdgeInsets,
                                              [value UIEdgeInsetsValue],
                                              UIEdgeInsetsEqualToEdgeInsets(oldVal, newVal));


TOKEN_SETTER_BLOCK_FUNCTION_BIG_STRUCT_IMP(CGRect,
                                              CGRect,
                                              [value CGRectValue],
                                              CGRectEqualToRect(oldVal, newVal));

TOKEN_SETTER_BLOCK_FUNCTION_BIG_STRUCT_IMP(CATransform3D,
                                              CATransform3D,
                                              [value CATransform3DValue],
                                              CATransform3DEqualToTransform(oldVal, newVal));

TOKEN_SETTER_BLOCK_FUNCTION_BIG_STRUCT_IMP(CGAffineTransform,
                                              CGAffineTransform,
                                              [value CGAffineTransformValue],
                                              CGAffineTransformEqualToTransform(oldVal, newVal));


#pragma make - function pointer
typedef id (*TokenGetterBlockFunction)(TokenSwizzleInfo *swizzleInfo, NSString *propertyName);
typedef id (*TokenSetterBlockFunction)(TokenSwizzleInfo *swizzleInfo, NSString *propertyName);

#pragma mark - object
id TokenGetterBlockTypeOfObject(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {
    return ^NSObject *(NSObject * _Nonnull instance) {
        NSObject * (*originalIMP)(__unsafe_unretained id, SEL);
        originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
        NSObject * origin = originalIMP(instance, swizzleInfo.selector);
        if (TokenIsEffectTracking()) {
            TokenReactiveTrack(instance, propertyName);
        }
        if (origin) {
            TokenObserve([origin class]);
        }
        return origin;
    };
}

static inline id TokenSetterBlockTypeOfObject(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {
    return ^void (NSObject * _Nonnull instance, NSObject *newVal){
        // 取旧值
        NSObject *oldVal = ((NSObject* (*)(id, SEL))objc_msgSend)(instance, NSSelectorFromString(propertyName));
        void (*originalIMP)(__unsafe_unretained id, SEL, typeof(newVal));
        originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
        originalIMP(instance, swizzleInfo.selector, newVal);
        if (oldVal != newVal) {
            TokenReactiveTrigger(instance, propertyName);
        }
    };
}

#pragma mark - public API
id TokenGetterImpBlockFactory(TokenSwizzleInfo *swizzleInfo, NSString *propertyName) {
    static NSDictionary *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = @{
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Object, NSObject *),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Long, long),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Char, char),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Int, int),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Short, short),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Float, float),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UnsignedChar, unsigned char),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UnsignedInt, unsigned int),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UnsignedShort, unsigned short),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UnsignedLong, unsigned long),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Double, double),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Bool, bool),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Class, Class),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(Sel, SEL),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CString, char *),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UIOffset, UIOffset),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(UIEdgeInsets, UIEdgeInsets),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CGSize, CGSize),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CGRect, CGRect),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CGPoint, CGPoint),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CGAffineTransform, CGAffineTransform),
            TOKEN_GETTER_BLOCK_KEY_VALUE_PAIR(CATransform3D, CATransform3D),
        };
    });
    NSString *funcKey = [[NSString alloc] initWithUTF8String:swizzleInfo.methodSignature.methodReturnType];
    NSValue  *funcValue = store[funcKey];
    if (funcValue) {
        TokenGetterBlockFunction func = [funcValue pointerValue];
        return func(swizzleInfo, propertyName);
    }
    return nil;
}

id TokenSetterImpBlockFactory(TokenSwizzleInfo *swizzleInfo,
                              NSString *propertyName,
                              const char *valueType) {
    
    static NSDictionary *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = @{
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Object, NSObject *),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Long, long),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Char, char),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Int, int),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Short, short),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Float, float),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UnsignedChar, unsigned char),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UnsignedInt, unsigned int),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UnsignedShort, unsigned short),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UnsignedLong, unsigned long),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Double, double),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Bool, bool),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Class, Class),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(Sel, SEL),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CString, char *),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UIOffset, UIOffset),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(UIEdgeInsets, UIEdgeInsets),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CGSize, CGSize),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CGRect, CGRect),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CGPoint, CGPoint),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CGAffineTransform, CGAffineTransform),
            TOKEN_SETTER_BLOCK_KEY_VALUE_PAIR(CATransform3D, CATransform3D),
        };
    });
    
    NSString *key = [[NSString alloc] initWithUTF8String:valueType];
    NSValue *funcValue = store[key];
    if (funcValue) {
        TokenSetterBlockFunction func = [funcValue pointerValue];
        return func(swizzleInfo, propertyName);
    }
    return nil;
}
