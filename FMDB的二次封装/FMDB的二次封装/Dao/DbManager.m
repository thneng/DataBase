//
//  DbManager.m
//  baoshanTest
//
//  Created by baoshan on 16/7/21.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import "DbManager.h"

/**
 *  使用 FMDatabaseQueue 操作数据库避免多线程操作同一个数据库时引起冲突，把数据库的操作放到一个串行队列中，从而保证不会在同一时间对数据库做改动。
 */

@implementation DbManager
/**
 *  单例
 */
+ (instancetype)getInstance{
    
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}
/**
 *  构造函数
 */
- (instancetype)init{
    
    if (self = [super init]) {
        [self initDatabase];
    }
    return self;
}

/**
 *  初始化
 */
- (void)initDatabase{
    
    long long userId;
    // 数据库路径
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                       stringByAppendingPathComponent:@"sunshineHealthy"]
                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu", userId]];
    
    // 创建数据库保存路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    
    NSString *dbPath = [path stringByAppendingString:@"sunshineHealthy.sqlite"];
    NSLog(@"数据库路径:[%@]",dbPath);
    
    //数据库队列
    _dbQueue = [[FMDatabaseQueue alloc]initWithPath:dbPath];
}


@end
