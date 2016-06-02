//
//  CreateModel.m
//  WallPaper
//
//  Created by YouXianMing on 15/6/2.
//  Copyright (c) 2015年 YouXianMing. All rights reserved.
//

#import "CreateModel.h"

@implementation CreateModel

- (void)createModel {
    if (self.modelName == nil ||
        self.inputDictionary == nil ||
        [self.inputDictionary isKindOfClass:[NSDictionary class]] == NO) {
        return;
    }
    
    // 创建头文件
    [self createHeaderFile];
    
    // 创建实现文件
    [self createContentFile];
    
    // 提示信息
    NSLog(@"生成的文件在以下路径中 \n%@", [self filePath]);
}

/**
 *  获取plist文件
 *
 *  @return 字典
 */
- (NSDictionary *)accessModelPlist {
    
    NSString     *path = [[NSBundle mainBundle] pathForResource:@"CreateModel.plist" ofType:nil];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return data;
}

/**
 *  创建头文件
 */
- (void)createHeaderFile {
    
    NSMutableString *headerFileString = [NSMutableString string];
    
    NSString *headerFileName  = [NSString stringWithFormat:@"%@.h", self.modelName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy/M/d"];
    NSString *dataString = [dateFormatter stringFromDate:[NSDate date]];
    // .h 文件头部信息
    NSString *head = \
    [NSString stringWithFormat:@"//\n//  %@.h\n//  ShangPin\n//\n//  Created by je_ffy on %@\n//\n//  Copyright (c) 2012年 feng lu. All rights reserved.\n//\n\n#import <Foundation/Foundation.h>\n\n@interface %@ : EPModel\n\n", self.modelName,dataString, self.modelName];
    [headerFileString appendString:head];
    

    // .h 中间信息
    NSString *middle = [self transformDictionary:self.inputDictionary];
    [headerFileString appendString:middle];
    
    [headerFileString appendString:@"\n\n@end\n\n"];
    
    // 写文件
    [headerFileString writeToFile:[self fullFilePathWithName:headerFileName]
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:nil];
}

/**  
 *  创建实现文件
 */
- (void)createContentFile {
    NSMutableString *contentFileString = [NSMutableString string];
    
    NSString *contentFileName = [NSString stringWithFormat:@"%@.m", self.modelName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy/M/d"];
    NSString *dataString = [dateFormatter stringFromDate:[NSDate date]];
    // .m 文件头部信息
    NSString *head = \
    [NSString stringWithFormat:@"//\n//  %@.m\n//  ShangPin\n//\n//  Created by je_ffy on %@\n//  Copyright (c) 2012年 feng lu. All rights reserved.\n//\n\n#import \"%@.h\"\n\n@implementation %@\n\n", self.modelName,dataString, self.modelName, self.modelName];
    [contentFileString appendString:head];
    
    // .m 中间信息
    NSDictionary *data = [self accessModelPlist];
    [contentFileString appendString:data[@"实现的源码"]];
    
    // .m 尾部信息
    [contentFileString appendString:@"\n\n\n@end\n\n"];
    
    // 写文件
    [contentFileString writeToFile:[self fullFilePathWithName:contentFileName]
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:nil];
}

/**
 *  获取沙盒路径
 *
 *  @return 沙盒路径
 */
- (NSString *)filePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Desktop"]];
}

- (NSString *)fullFilePathWithName:(NSString *)fileName {
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Desktop/%@", fileName]];
}

/**
 *  将字典转换成相对应的属性
 *
 *  @param dictionary 输入的字典
 *
 *  @return 字符串
 */
- (NSString *)transformDictionary:(NSDictionary *)dictionary {
    
    NSMutableString *string = [NSMutableString string];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]]) {
            if ([dictionary[key] isKindOfClass:[NSString class]]) {
                [string appendString:[NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;\n", key]];
            } else if ([dictionary[key] isKindOfClass:[NSNumber class]]) {
                [string appendString:[NSString stringWithFormat:@"@property (nonatomic, strong) NSNumber *%@;\n", key]];
            } else if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
                [string appendString:[NSString stringWithFormat:@"@property (nonatomic, strong) NSDictionary *%@;\n", key]];
            } else if ([dictionary[key] isKindOfClass:[NSArray class]]) {
                [string appendString:[NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;\n", key]];
            } else {
                [string appendString:[NSString stringWithFormat:@"//@property (nonatomic, strong) %@     *%@;\n", [dictionary[key] class],key]];
            }
        }
    }];
    
    return string;
}

+ (void)createFileWithModelName:(NSString *)modelName dictionary:(NSDictionary *)dictionary {
    
    CreateModel *model    = [CreateModel new];
    model.modelName       = modelName;
    model.inputDictionary = dictionary;
    
    [model createModel];
}

@end
