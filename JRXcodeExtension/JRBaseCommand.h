//
//  JRBaseCommand.h
//  JRSourceExtension
//
//  Created by J on 2016/10/12.
//  Copyright © 2016年 J. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

@interface JRBaseCommand : NSObject <XCSourceEditorCommand>

- (void)handlerCommandInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end
