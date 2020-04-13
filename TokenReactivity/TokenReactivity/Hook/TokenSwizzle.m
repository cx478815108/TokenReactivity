//
//  TokenHook.m
//  TokenReactivity
//
//  Created by 陈雄 on 2020/3/10.
//  Copyright © 2020 krauschen. All rights reserved.
//

#import "TokenSwizzle.h"
#import <objc/runtime.h>

#pragma mark - Block HelpeReactive
#if !defined(NS_BLOCK_ASSERTIONS)

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpeReactive have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};
typedef int BlockFlags;

static const char *blockGetType(id block){
    struct Block_literal_1 *blockRef = (__bridge struct Block_literal_1 *)block;
    BlockFlags flags = blockRef->flags;
    
    if (flags & BLOCK_HAS_SIGNATURE) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        
        if (flags & BLOCK_HAS_COPY_DISPOSE) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        
        const char *signature = (*(const char **)signatureLocation);
        return signature;
    }
    
    return NULL;
}

static BOOL blockIsCompatibleWithMethodType(id block, const char *methodType){
    
    const char *blockType = blockGetType(block);
    
    NSMethodSignature *blockSignature;
    
    if (0 == strncmp(blockType, (const char *)"@\"", 2)) {
        // Block return type includes class name for id types
        // while methodType does not include.
        // Stripping out return class name.
        char *quotePtr = strchr(blockType+2, '"');
        if (NULL != quotePtr) {
            ++quotePtr;
            char filteredType[strlen(quotePtr) + 2];
            memset(filteredType, 0, sizeof(filteredType));
            *filteredType = '@';
            strncpy(filteredType + 1, quotePtr, sizeof(filteredType) - 2);
            
            blockSignature = [NSMethodSignature signatureWithObjCTypes:filteredType];
        }else{
            return NO;
        }
    }else{
        blockSignature = [NSMethodSignature signatureWithObjCTypes:blockType];
    }
    
    NSMethodSignature *methodSignature =
        [NSMethodSignature signatureWithObjCTypes:methodType];
    
    if (!blockSignature || !methodSignature) {
        return NO;
    }
    
    if (blockSignature.numberOfArguments != methodSignature.numberOfArguments){
        return NO;
    }
    
    if (strcmp(blockSignature.methodReturnType, methodSignature.methodReturnType) != 0) {
        return NO;
    }
    
    for (int i=0; i<methodSignature.numberOfArguments; ++i){
        if (i == 0){
            // self in method, block in block
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], "@") != 0) {
                return NO;
            }
            if (strcmp([blockSignature getArgumentTypeAtIndex:i], "@?") != 0) {
                return NO;
            }
        }else if(i == 1){
            // SEL in method, self in block
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], ":") != 0) {
                return NO;
            }
            if (strncmp([blockSignature getArgumentTypeAtIndex:i], "@", 1) != 0) {
                return NO;
            }
        }else {
            const char *blockSignatureArg = [blockSignature getArgumentTypeAtIndex:i];
            
            if (strncmp(blockSignatureArg, "@?", 2) == 0) {
                // Handle function pointer / block arguments
                blockSignatureArg = "@?";
            }
            else if (strncmp(blockSignatureArg, "@", 1) == 0) {
                blockSignatureArg = "@";
            }
            
            if (strcmp(blockSignatureArg,
                       [methodSignature getArgumentTypeAtIndex:i]) != 0)
            {
                return NO;
            }
        }
    }
    
    return YES;
}

static BOOL blockIsAnImpFactoryBlock(id block){
    const char *blockType = blockGetType(block);
    TokenSwizzleImpFactoryBlock dummyFactory = ^id(TokenSwizzleInfo *swizzleInfo){
        return nil;
    };
    const char *factoryType = blockGetType(dummyFactory);
    return 0 == strcmp(factoryType, blockType);
}

#endif


#pragma mark - Swizzling
#pragma mark - TokenSwizzleInfo
typedef IMP (^TokenSwizzleImpProvider)(void);

@interface TokenSwizzleInfo()
@property (nonatomic, copy) TokenSwizzleImpProvider impProviderBlock;
@property (nonatomic, readwrite) NSMethodSignature *methodSignature;
@property (nonatomic, readwrite) SEL selector;
@end

@implementation TokenSwizzleInfo

-(TokenSwizzleOriginalIMP)getOriginalImplementation{
    NSAssert(_impProviderBlock,nil);
    return (TokenSwizzleOriginalIMP)_impProviderBlock();
}

@end

BOOL TokenSwizzle(Class classToSwizzle, SEL selector, TokenSwizzleImpFactoryBlock factoryBlock)
{
    Method method = class_getInstanceMethod(classToSwizzle, selector);
    NSCAssert(NULL != method,
              @"Selector %@ not found in %@ methods of class %@.",
              NSStringFromSelector(selector),
              class_isMetaClass(classToSwizzle) ? @"class" : @"instance",
              classToSwizzle);
    
    NSCAssert(blockIsAnImpFactoryBlock(factoryBlock),
             @"Wrong type of implementation factory block.");

    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    __block IMP originalIMP = NULL;
    
    TokenSwizzleImpProvider originalImpProvider = ^IMP{
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        IMP imp = originalIMP;
        dispatch_semaphore_signal(lock);
        
        if (NULL == imp){
            Class superclass = class_getSuperclass(classToSwizzle);
            imp = method_getImplementation(class_getInstanceMethod(superclass,selector));
        }
        return imp;
    };
    
    const char *methodType = method_getTypeEncoding(method);
    
    TokenSwizzleInfo *swizzleInfo = [[TokenSwizzleInfo alloc] init];
    swizzleInfo.selector          = selector;
    swizzleInfo.impProviderBlock  = originalImpProvider;
    swizzleInfo.methodSignature   = [NSMethodSignature signatureWithObjCTypes:methodType];

    id newIMPBlock = factoryBlock(swizzleInfo);
    if (newIMPBlock) {
        NSCAssert(blockIsCompatibleWithMethodType(newIMPBlock, methodType),
                  @"Block returned from factory is not compatible with method type.");
        
        IMP newIMP = imp_implementationWithBlock(newIMPBlock);
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        originalIMP = class_replaceMethod(classToSwizzle, selector, newIMP, methodType);
        dispatch_semaphore_signal(lock);
        return YES;
    }
    return NO;
}


