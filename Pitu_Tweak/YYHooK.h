//
//  YYHooK.h
//  Waterlogue
//
//  Created by hongyangyi on 15/6/24.
//
//
#include <vector>
#include <substrate.h>
#include <logos/logos.h>
#import <UIKit/UIKit.h>

//static void YYHooKMessage(NSString* className,NSString* messageName);

@interface YYHook : NSObject
+ (void)YYHookMessage:(NSString *)className messageName:(NSString *)messageName;
+ (void)YYHookMessage:(NSString *)className
          messageName:(NSString *)messageName
           completion:(BOOL (^)(id object,SEL sel,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8 ))completion;
@end

