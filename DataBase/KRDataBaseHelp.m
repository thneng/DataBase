//
//  KRDataBaseHelp.m
//  SunshineHealthy
//
//  Created by James Hsu on 3/25/16.
//  Copyright © 2016 深圳市凯如科技有限公司. All rights reserved.
//

#import "KRDataBaseHelp.h"
#import "FMDB/FMDB.h"

#define KRFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"sunshinehealthy.sqlite"]

@interface KRDataBaseHelp ()

@property (nonatomic, strong) KRBaseData* queue;

@end


@implementation KRDataBaseHelp

- (id)init
{
    self = [super init];
    
    if(self){
        
        _queue = [KRBaseData databaseQueueWithPath:KRFilePath];
    }
    return self;
}

/**
 * 数据库的单例
 */
+ (KRDataBaseHelp *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        
        _sharedObject = [[self alloc] init];
        
        
    });
    return _sharedObject;
}

/**
 * 操作数据库的回调
 */
- (void)inDatabase:(void(^)(FMDatabase*))block
{
    [_queue inDatabase:^(FMDatabase *db){
        
        block(db);
    }];
}

- (void)executeUpdateWithTableName:(NSString *)name
                          withData:(NSDictionary *)parame
                           SQLType:(SQLtype)type
                          baseData:(FMDatabaseBlock)block
{
    [_queue executeUpdateWithTableName:name withData:parame SQLType:type baseData:^(BOOL ressult, KRSQLModel *objc) {
        if (block) {
            block(ressult, objc);
        }
    }];
}

/**
 * 查找专用
 * @param value -- uid 唯一标示
 * @param listId -- 主键 序列号（最后一个序列号)
 * @param limit -- 每次取得个数
 */
- (void)searchTableName:(NSString *)name
                withUid:(NSString *)value
                 listId:(NSString *)listId
                  limit:(NSInteger)limit
               baseData:(FMDatabaseBlock)block
{
    [_queue queryTableWithName:name uidValue:value listId:listId limit:limit baseData:^(BOOL ressult, KRSQLModel *sqlModel) {
        if (block) {
            block(ressult, sqlModel);
        }
    }];
}
/**
 根据uid 查找
 
 @param uid 输入uid
 
 @return 返回一个字典信息
 */
- (NSDictionary *)searchUserWithUid:(NSString *)uid
{
    NSArray *results = [_queue queryTableWithName:KRUserTableName uidValue:uid];
    
    if (results && results.count > 0) {
        return [results lastObject];
    }
    
    return nil;
}

/**
 查找数据

 @param name   表名称
 @param parame 参数

 @return 字典
 */
- (NSDictionary *)searchTableName:(NSString *)name withData:(NSDictionary *)parame
{
    return [_queue searchTableName:name parame:parame];
}

- (void)deleteTableName:(NSString *)name
                withUid:(NSString *)value
             WithStatus:(NSString *)status
               baseData:(FMDatabaseBlock)block
{
}

@end
