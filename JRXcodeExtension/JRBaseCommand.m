//
//  JRBaseCommand.m
//  JRSourceExtension
//
//  Created by J on 2016/10/12.
//  Copyright © 2016年 J. All rights reserved.
//

#import "JRBaseCommand.h"

@implementation JRBaseCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    
    if (![invocation.commandIdentifier rangeOfString:NSStringFromClass(self.class)].length) {
        completionHandler(nil);
    }
    [self handlerCommandInvocation:invocation];
    completionHandler(nil);
}

- (void)handlerCommandInvocation:(XCSourceEditorCommandInvocation *)invocation {}

@end
