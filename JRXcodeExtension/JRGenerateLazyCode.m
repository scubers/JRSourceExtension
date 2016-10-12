//
//  JRGenerateLazyCode.m
//  JRSourceExtension
//
//  Created by J on 2016/9/23.
//  Copyright © 2016年 J. All rights reserved.
//

#import "JRGenerateLazyCode.h"

@interface JRLazyObject : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL needStar;
@end

@implementation JRLazyObject
@end

@interface JRGenerateLazyCode ()
@end

@implementation JRGenerateLazyCode

- (void)handlerCommandInvocation:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    
    NSInteger startLine = range.start.line;
    NSInteger endLine = range.end.line;
    
    if (startLine >= invocation.buffer.lines.count) {
        return;
    }
    
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    if (startLine == endLine) {
        [lines addObject:[invocation.buffer.lines[startLine] copy]];
    } else {
        for (NSInteger i = startLine; i <= endLine; i++) {
            [lines addObject:[invocation.buffer.lines[i] copy]];
        }
    }

    NSMutableArray *newLines = [NSMutableArray array];
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JRLazyObject *lazy = [self checkGenerateTypeForString:obj];
        if (lazy) {
            [newLines addObject:[NSString stringWithFormat:@"- (%@%@)%@ {", lazy.type, lazy.needStar?@" *":@"", lazy.name]];
            [newLines addObject:[NSString stringWithFormat:@"    if (!_%@) {", lazy.name]];
            [newLines addObject:[NSString stringWithFormat:@"        _%@ = [[%@ alloc] init];", lazy.name, lazy.type]];
            [newLines addObject:[NSString stringWithFormat:@"    }"]];
            [newLines addObject:[NSString stringWithFormat:@"    return _%@;", lazy.name]];
            [newLines addObject:[NSString stringWithFormat:@"}"]];
        }
    }];
    
    for (NSUInteger i = invocation.buffer.lines.count; i > 0 ; i--) {
        if ([invocation.buffer.lines[i - 1] hasPrefix:@"@end"]) {
            [newLines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [invocation.buffer.lines insertObject:obj atIndex:i - 1];
            }];
            break;
        }
    }
}

- (JRLazyObject *)checkGenerateTypeForString:(NSString *)line {
    NSError *error;
    NSRegularExpression *reg =
    [NSRegularExpression regularExpressionWithPattern:@"^@property"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    
    
    NSArray<NSTextCheckingResult *> * array =
    [reg matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
    
    if (!array.count) {
        return nil;
    }
    
    JRLazyObject *obj = [JRLazyObject new];
    
    // 检查带 * 的
    // @property (nonatomic, strong) NSString *abc;
    reg =
    [NSRegularExpression regularExpressionWithPattern:@"[0-9a-zA-Z_]+\\ *\\*\\ *[0-9a-zA-Z_]+"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    array =
    [reg matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
    if (array.count) {
        NSString *string = [line substringWithRange:array.firstObject.range];// NSString *abc
        obj.type = [[string componentsSeparatedByString:@"*"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        obj.name = [[string componentsSeparatedByString:@"*"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        obj.needStar = YES;
        return obj;
    }
    
    // 检查不带 * 的
    // @property (nonatomic, assign) int abc;
    reg =
    [NSRegularExpression regularExpressionWithPattern:@"[0-9a-zA-Z_]+\\ +[0-9a-zA-Z_]+\\ *;"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    array =
    [reg matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
    if (array.count) {
        NSString *string = [line substringWithRange:array.firstObject.range];// int abc
        string = [[string substringToIndex:string.length - 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        obj.type = [[string componentsSeparatedByString:@" "].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        obj.name = [[string componentsSeparatedByString:@" "].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return obj;
    }
    
    // 检查 block 的
    // @property (nonatomic, assign) void (^abc)();
    reg =
    [NSRegularExpression regularExpressionWithPattern:@"[0-9a-zA-Z_]+\\ *\\*?\\(\\^[0-9a-zA-Z_]+\\)\\(.*\\)"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    array =
    [reg matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
    if (array.count) {
        NSString *string = [line substringWithRange:array.firstObject.range];// int abc
        
        obj.name = [[string substringToIndex:[string rangeOfString:@")"].location] substringFromIndex:[string rangeOfString:@"^"].location + 1];
        obj.type = [string stringByReplacingOccurrencesOfString:obj.name withString:@""];
        
        return obj;
    }
    
    return nil;
}

@end









