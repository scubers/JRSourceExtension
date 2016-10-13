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
    [NSRegularExpression regularExpressionWithPattern:@"\\w+(<.+>)? *\\* *\\w+ *;"
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    array =
    [reg matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
    if (array.count) {
        NSString *string = [line substringWithRange:array.firstObject.range];// NSString *abc
        reg = [NSRegularExpression regularExpressionWithPattern:@"\\w+(<.+>)? *\\*" options:NSRegularExpressionCaseInsensitive error:&error];
        array = [reg matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
        obj.type = [string substringWithRange:array.firstObject.range];
        obj.type = [[obj.type substringToIndex:obj.type.length - 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        reg = [NSRegularExpression regularExpressionWithPattern:@"\\* *\\w+ *;" options:NSRegularExpressionCaseInsensitive error:&error];
        array = [reg matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
        obj.name = [string substringWithRange:array.firstObject.range];
        obj.name = [[[obj.name substringToIndex:obj.name.length - 1] substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        obj.needStar = YES;
        return obj;
    }
    
    return nil;// 后面都不要了，一般都是对象才会需要 懒加载
    
}

@end









