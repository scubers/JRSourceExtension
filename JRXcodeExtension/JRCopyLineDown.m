//
//  JRCopyLineDown.m
//  JRXcodeExtension
//
//  Created by J on 2016/9/23.
//  Copyright © 2016年 J. All rights reserved.
//

#import "JRCopyLineDown.h"

@implementation JRCopyLineDown

- (void)handlerCommandInvocation:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;

    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    
    if (startLine >= invocation.buffer.lines.count) {
        return;
    }
    
    NSMutableArray *newlines = [NSMutableArray array];
    if (startLine == endLine) {
        [newlines addObject:[invocation.buffer.lines[startLine] copy]];
    } else {
        for (NSInteger i = startLine; i <= endLine; i++) {
            [newlines addObject:[invocation.buffer.lines[i] copy]];
        }
    }
    
    [newlines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [invocation.buffer.lines insertObject:obj atIndex:startLine];
    }];
    
    // 设置selections
    XCSourceTextPosition start = (XCSourceTextPosition){startLine + newlines.count, 0};
    XCSourceTextPosition end = (XCSourceTextPosition){endLine + newlines.count, invocation.buffer.lines[endLine + newlines.count].length - 1};
    range = [[XCSourceTextRange alloc] initWithStart:start end:end];
    [invocation.buffer.selections removeAllObjects];
    [invocation.buffer.selections addObject:range];
}

@end
