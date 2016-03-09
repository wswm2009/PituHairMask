//
//  YYHooK.cpp
//  Waterlogue
//
//  Created by hongyangyi on 15/6/24.
//
//

#include "YYHooK.h"


class ClassMessage
{
public:
    NSString *className;
    NSString *messageName;
    void *funpoint;
};

typedef BOOL (^Callback)(id object,SEL sel,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8);

@interface YYHookMessage : NSObject
@property (nonatomic, copy) Callback callback;
@property (nonatomic, copy) NSString *messageName;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, assign) ClassMessage *classMessage;

@end

@implementation YYHookMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _classMessage = new ClassMessage;
    }
    return self;
}

@end




static std::vector<ClassMessage*> classmessagearray;
static id MyFun(id self,SEL _cmd,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8);

@interface YYHook ()
@property (nonatomic, strong) NSMutableArray *blocks;
@end

@implementation YYHook

- (instancetype)init
{
    self = [super init];
    if (self) {
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedYYHook
{
    static id object;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[self alloc] init];
    });
    return object;
}

+ (void)YYHookMessage:(NSString *)className messageName:(NSString *)messageName
{
    [self YYHookMessage:className
            messageName:messageName
             completion:nil];
}

+ (void)YYHookMessage:(NSString *)className
          messageName:(NSString *)messageName
           completion:(BOOL (^)(id object,SEL sel,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8 ))completion
{
//    ClassMessage *classmessage  = new ClassMessage;
//    classmessage->className = className;
//    classmessage->messageName = messageName;
//    classmessagearray.push_back(classmessage);
    
    
    YYHookMessage *message = [[YYHookMessage alloc] init];
    message.messageName = messageName;
    message.callback = completion;
    message.className = className;
    [[[YYHook sharedYYHook] blocks] addObject:message];
    
    MSHookMessageEx(NSClassFromString(className), NSSelectorFromString(messageName), (IMP)&MyFun, (IMP*)&message.classMessage->funpoint);

}

@end

static id MyFun(id self,SEL _cmd,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8)
{
    BOOL needContinue = NO;
    id (*OldFun)(id self,SEL _cmd,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8);
    for (YYHookMessage *message in [[YYHook sharedYYHook] blocks]) {
        if ([message.messageName isEqualToString:NSStringFromSelector(_cmd)] &&
            [message.className isEqualToString:NSStringFromClass([self class])]) {
            
            if (message.callback) {
                needContinue =  message.callback(self,_cmd,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8);
                if (needContinue) {
                    OldFun = (id(*)(id,SEL,id,id,id,id,id,id,id,id) )message.classMessage->funpoint;
                    return OldFun(self,_cmd,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8);
                }
            }
        }
    }
    
//    if (needContinue) {
//        id (*OldFun)(id self,SEL _cmd,id arg1,id arg2,id arg3,id arg4,id arg5,id arg6,id arg7,id arg8);
//        for (int i=0; i<classmessagearray.size(); i++)
//        {
//            if([classmessagearray[i]->className isEqualToString:NSStringFromClass([self class])]
//               &&[classmessagearray[i]->messageName isEqualToString:NSStringFromSelector(_cmd)])
//            {
//                OldFun=(id(*)(id,SEL,id,id,id,id,id,id,id,id) )classmessagearray[i]->funpoint;
//                
//            }
//        }
//    }
    
    
    
//    if ([NSStringFromClass([self class]) isEqualToString:@"WAPaintingViewController"]
//        &&[NSStringFromSelector(_cmd) isEqualToString:@"setSourceImage:"])
//    {
//        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:NSStringFromClass([self class]) message:NSStringFromSelector(_cmd) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [alertview show];
//    }
//    
//    if ([NSStringFromClass([self class]) isEqualToString:@"WAPaintingViewController"]
//        &&[NSStringFromSelector(_cmd) isEqualToString:@"doPaint:"])
//    {
//        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:NSStringFromClass([self class]) message:NSStringFromSelector(_cmd) delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [alertview show];
//    }
//    
//    
//    
//    
//
//    for (int i=0; i<classmessagearray.size(); i++)
//    {
//        if([classmessagearray[i]->className isEqualToString:NSStringFromClass([self class])]
//           &&[classmessagearray[i]->messageName isEqualToString:NSStringFromSelector(_cmd)])
//        {
//            OldFun=(id(*)(id,SEL,id,id,id,id,id,id,id,id) )classmessagearray[i]->funpoint;
//            break;
//        }
//    }
    
}
