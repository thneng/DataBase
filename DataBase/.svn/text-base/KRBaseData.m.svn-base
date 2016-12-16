//
//  KRBaseData.m
//  SunshineHealthy
//
//  Created by James Hsu on 3/25/16.
//  Copyright © 2016 深圳市凯如科技有限公司. All rights reserved.
//

#import "KRBaseData.h"

@implementation KRBaseData

/**
 *  操作数据库的回调
 *
 *  @param name   数据库表名
 *  @param parame 传入字典
 *  @param type   操作类型
 *  @param block  数据库实例对象
 */
- (void)executeUpdateWithTableName:(NSString *)name
                          withData:(NSDictionary *)parame
                           SQLType:(SQLtype)type
                          baseData:(FMDatabaseBlock)block;
{
    [self inDatabase:^(FMDatabase *db) {
        
        
         //这里 处理 parame里的 key - value 数据...
        
        
        if (!(parame && parame.allKeys.count > 0)) {
            
            self.SqlModel.errorMessage = @"parame must not be nil";
            self.SqlModel.errorCode = KRErrorCodeParameNULL;
            block(NO,self.SqlModel);
            
            
            return ;
        }
        
        NSMutableDictionary *dic = [self dictionaryConfig:parame withTable:name];
        
        // 判断 name 表是否存在,不存在就新建此表
        BOOL isExe = [self isExecuteUpdateWithName:name data:dic];
        
        if (isExe) {
            
            switch (type) {
                case SQLtypeInsert:
                {
                    BOOL isInsert = [self insertTableWithName:name data:dic];
                    
                    if (isInsert) {
                        self.SqlModel.errorCode = 0;
                        self.SqlModel.errorMessage = @"successful";
                    }
                    
                    block(isInsert, self.SqlModel);
                }
                    break;
                    
                case SQLtypeUpdate:
                {
                    BOOL isUpdate = [self updateTableWithName:name data:dic];
                    if (isUpdate) {
                        self.SqlModel.errorCode = 0;
                        self.SqlModel.errorMessage = @"successful";
                    }
                    block(isUpdate, self.SqlModel);
                }
                    break;
                    
                case SQLtypeQuery:
                {
                    self.SqlModel.results = [self queryTableWithName:name uidValue:dic[@"uid"]];
                    
                    block(YES, self.SqlModel);
                }
                    
                    break;
                    
                case SQLTypeDelete:
                {
                    BOOL isDelete = [self deleteTableWithName:name data:dic[@"uid"]];
                    if (isDelete) {
                        self.SqlModel.errorCode = 0;
                        self.SqlModel.errorMessage = @"successful";
                    }
                    block(isDelete, self.SqlModel);
                }
                    
                    break;
                    
                default:
                    [SVProgressHUD showInfoWithStatus:@"不支持此种类型"];
                    break;
            }
            
        }else
        {
            block(NO, self.SqlModel);
        }

    }];
}
/**
 * 构造表数据
 */
- (NSMutableDictionary *)dictionaryConfig:(NSDictionary *)dictionary withTable:(NSString *)name
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    if (!data) {
        [dic setObject:@"" forKey:@"data"];
    } else {
        [dic setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:@"data"];
    }
    
#pragma mark --- 这里做不同数据表的差异判断
    if ([name isEqualToString:KRUserTableName]) {
        
        NSString *value = dictionary[@"uid"];
        
        if (value && value.length > 0) {
            [dic setObject:dictionary[@"uid"] forKey:@"uid"];
        }else
        {
            NSAssert(value,@"value for key 'uid' is null");
        }
    }else if ([name isEqualToString:KRAddressBookName])
    {
        // 唯一标示
        NSString *value = DATAMODEL.uid;
        
        [dic setObject:value forKey:@"uid"];
    }else if ([name isEqualToString:KRFriendsName])
    {
        NSString *value = DATAMODEL.uid;
        [dic setObject:value forKey:@"uid"];
    }else if ([name isEqualToString:KRAddressName])
    {
        // 这里为固定值，表示为配置数据，具有唯一性
        NSString *value = @"address";
        [dic setObject:value forKey:@"uid"];
    }else if ([name isEqualToString:KRCityName] || [name isEqualToString:KRAreaName])
    {
        // 这里的value 为城市所属省的code
        NSString *value = dictionary[@"uid"];
        [dic setObject:value forKey:@"uid"];
    }else if ([name isEqualToString:KRHealthyCaseName])
    {
        // 这里的uid为 用户id和孩子id的组合，生成新的唯一标示
        NSString *value = [NSString stringWithFormat:@"%@%@",dictionary[@"uid"],dictionary[@"childId"]];
        [dic setObject:value forKey:@"uid"];
    }else
    {
        // 唯一标示
        NSString *value = DATAMODEL.uid;
        [dic setObject:value forKey:@"uid"];
    }

    return dic;
}

/**
 *  创建数据库表
 *
 *  @param name   数据库名
 *  @param parame  数组
 *
 *  @return 是否成功
 */
- (BOOL)isExecuteUpdateWithName:(NSString *)name data:(NSDictionary *)parame
{

    // sql 语句
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key autoincrement, uid text, data text);",name];
    
    BOOL userInfoFlag = [_db executeUpdate:sql];
    if (userInfoFlag) {
        KRLog(@"创建用户信息表成功");
    }else{
        KRLog(@"创建用户信息表失败");
    }
    
    return userInfoFlag;
    
}

/**
 *  插入数据库
 *
 *  @param name   数据库名
 *  @param parame  数组
 *
 *  @return 是否成功
 */
- (BOOL)insertTableWithName:(NSString *)name data:(NSDictionary *)parame
{

    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO %@ (uid, data) VALUES ('%@', '%@');", name, parame[@"uid"], parame[@"data"]];

    BOOL result = NO;
    
    result = [_db executeUpdate:sqlString];
    
    if (!result) {
        self.SqlModel.errorMessage = @"insert error";
        self.SqlModel.errorCode = KRErrorCodeInsert;
    }
    return result;
}

/**
 *  查询数据库
 *
 *  @param name  数据库表名
 *  @param key   查询的 key
 *  @param value  查询结果
 *
 *  @return 是否成功
 */
- (BOOL)queryTableWithName:(NSString *)name
                       key:(NSString *)key
                     value:(NSString *)value
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?;", name, key];
    
    FMResultSet *result = [_db executeQuery:sql,value];
    
    if ([result next])
    {
        return YES;
        
    }
    
    return NO;
}

/**
 *  查询数据库返回集合
 *
 *  @param name  数据库表名
 *  @param value  uid(当 uid 为空时返回当前所查询的表前十条数据, uid 有值返回 uid 等于 value 的数据)
 *
 *  @return  集合
 */
- (NSMutableArray *)queryTableWithName:(NSString *)name uidValue:(NSString *)value
{
    NSMutableArray *array = [NSMutableArray array];
    if (value) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = ?;", name];
        FMResultSet *result = [_db executeQuery:sql,value];
        while ([result next]) {
            
            NSData *data = [[result stringForColumn:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (!dic) {
#pragma mark-- 字典为空会崩溃
//           NSAssert(dic, @"data is not empty");
            } else {
                [array addObject:dic];
            }
        }
        return array;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ asc limit 10;", name];
    FMResultSet *result = [_db executeQuery:sql, value];
    while ([result next]) {
        NSData *data = [[result stringForColumn:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (!dic) {
            NSAssert(dic, @"data is not empty");
        } else {
            [array addObject:dic];
        }

    }
    
    return array;
}

- (void)queryTableWithName:(NSString *)name
                  uidValue:(NSString *)value
                    listId:(NSString *)listId
                     limit:(NSInteger)limit
                  baseData:(FMDatabaseBlock)block
{
    
    [self inDatabase:^(FMDatabase *db) {
        // 判断 name 表是否存在,不存在就新建此表
        BOOL isExe = [self isExecuteUpdateWithName:name data:nil];
        NSMutableArray *array = [NSMutableArray array];
        if (isExe) {
            if (value) {
                
                NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = ? ORDER BY id DESC LIMIT %ld", name,limit];
                
                if (![listId isEqualToString:@"0"]) {
                    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = ? AND id < ? ORDER BY id DESC LIMIT %ld", name,limit];
                }
                
                FMResultSet *result = [_db executeQuery:sql,value,listId];
                while ([result next]) {
                    NSData *data = [[result stringForColumn:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (!dic) {
                        NSAssert(dic, @"data is not empty");
                    } else {
                        if ([name isEqualToString:KRHealthyCaseName]) {
                            [dic setObject:[result stringForColumn:@"id"] forKey:@"caseId"];
                        }else if ([name isEqualToString:KRWeiBoPostName])
                        {
                            [dic setObject:[result stringForColumn:@"id"] forKey:@"local_id"];
                        }
                        [array addObject:dic];
                    }
                }
                
                self.SqlModel.results = array;
            }
        }else
        {
            self.SqlModel.results = array;
        }
        
        block(YES,self.SqlModel);
        
    }];

}

/**
 *  更新数据库
 *
 *  @param name   数据库名
 *  @param parame  数组
 *
 *  @return 是否成功
 */
- (BOOL)updateTableWithName:(NSString *)name data:(NSDictionary *)parame
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ set data = '%@' WHERE uid = ?;", name, parame[@"data"]];
    
    NSString *key = NULL;
    NSString *value = NULL;
    
    key = @"uid";
    value = parame[@"uid"];
    
    BOOL isUpdate = NO;
    BOOL isQuery = [self queryTableWithName:name key:key value:value];

    if (isQuery) {
        
        /// update
        isUpdate = [_db executeUpdate:sql,parame[@"uid"]];
    }else
    {
        /// insert
        return [self insertTableWithName:name data:parame];
    }

    if (!isUpdate) {
        self.SqlModel.errorMessage = @"update error";
        self.SqlModel.errorCode = KRErrorCodeUpdate;
    }
    
    return isUpdate;
}

/**
 *  删除数据库
 *
 *  @param name   数据库名
 *  @param parame  数组
 *
 *  @return 是否成功
 */
- (BOOL)deleteTableWithName:(NSString *)name data:(NSDictionary *)parame
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uid = ?;", name];
    
    BOOL isDelete = [_db executeUpdate:sql, parame[@"uid"]];
    return isDelete;
}
/**
 查找数据

 @param name   数据库名
 @param parame 数组

 @return 集合
 */
- (NSDictionary *)searchTableName:(NSString *)name parame:(NSDictionary *)parame
{
    NSMutableDictionary *dic = [self dictionaryConfig:parame withTable:name];
    
    NSArray *results = [self queryTableWithName:name uidValue:dic[@"uid"]];
    
    if (results.count > 0) {
        return results.lastObject;
    }
    return nil;
}


- (KRSQLModel *)SqlModel
{
    if (!_SqlModel) {
        _SqlModel = [[KRSQLModel alloc] init];
    }
    
    return _SqlModel;
}

@end


@implementation KRSQLModel

- (NSArray *)results
{
    if (!_results) {
        _results = [NSArray array];
    }
    return _results;
}


@end


