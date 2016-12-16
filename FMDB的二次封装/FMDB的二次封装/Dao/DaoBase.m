//
//  DaoBase.m
//  baoshanTest
//
//  Created by baoshan on 16/8/17.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import "DaoBase.h"
#import "RuntimeModel.h"
#import <objc/runtime.h>


@implementation DaoBase{

    FMDatabase *_db;
}

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

    //根据userid来区分用户
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
    NSLog(@"数据库路径:%@",dbPath);
    
    //数据库队列
    _dbQueue = [[FMDatabaseQueue alloc]initWithPath:dbPath];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        _db = db;
    }];
}

#pragma mark - 插入
/**
 *  存储
 */
- (void) saveData:(RuntimeModel *)model{

    if (![_db open]) {
        
    }else{
        
        //类名转string
        NSString *tableName = NSStringFromClass(model.class);
        
        NSMutableArray *childModels = [NSMutableArray array];
        //建表
        [self createTable:tableName fmdb:_db];
        
        
        //model属性转字典
        NSArray *members = model.allMembers.allKeys;
        
        //sql语句
        NSMutableString *firstSql = [[NSMutableString alloc]initWithString:@"("];
        NSMutableString *valueSql = [[NSMutableString alloc]initWithString:@"VALUES("];
        
        //将元素值放在数组中
        NSMutableArray *arr = [NSMutableArray array];
        for (NSInteger i = 0; i < members.count; i ++) {
            
            //获得属性的值
            id data = [self returnContent:model withKey:members[i]];
            NSInteger type = [model.allMembers[members[i]] integerValue];
            //判断数据类型
            if (type == DBDataTypeMODEL) {
                //有内嵌的model
                //避免添加nil对象
               if(data) [childModels addObject:data];
                
            }else if (type == DBDataTypeERROR){
                
                NSLog(@"无法识别的类型");
                break;
            }
            else{
                
                //基本类型（text，int，bool）
                [arr addObject:data];
                [firstSql appendString:[NSString stringWithFormat:@"%@",members[i]]];
                [valueSql appendString:@"?"];
                
            }
            //处理sql语句
            if (i == members.count - 1) {
                
                if (type == DBDataTypeMODEL) {
                    //最后一位是model，去除逗号
                    if ([firstSql hasSuffix:@","]) {
                        [firstSql deleteCharactersInRange:NSMakeRange([firstSql length] - 1, 1)];
                        
                    }
                    if ([valueSql hasSuffix:@","]) {
                        [valueSql deleteCharactersInRange:NSMakeRange([valueSql length] - 1, 1)];
                    }
                }
                
                //最后一位，添加括号
                [firstSql appendString:@")"];
                [valueSql appendString:@")"];
            }else if(i < members.count - 1 && type < 3){
                
                [firstSql appendString:@","];
                [valueSql appendString:@","];
            }
            
        }
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ %@ %@",tableName,firstSql,valueSql];
        
        BOOL res = [_db executeUpdate:sql values:arr error:nil];
        if (!res) {
            NSLog(@"error when insert db table");
            NSLog(@"error:%@",[NSString stringWithFormat:@"%@",_db.lastError]);
        }else{
            
            NSLog(@"success to insert db table");
            
            //查看是否有子model
        }
        [childModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //递归
            [self saveData:obj];
        }];
        
        //关闭
        [_db close];
        
    }
}

#pragma mark -  更新

/**
 *  更新数据
 *
 *  @param model 需要更新
 */
- (void) updateData:(RuntimeModel *)model {

    [self updateData:model mainKey:nil];
}

- (void) updateData:(RuntimeModel *) model mainKey:(NSString *)key {

   
       
        if (![_db open]) {
            
            NSLog(@"打开db失败!");
            
        }else{
        
            //sql更新语句
            NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set",NSStringFromClass(model.class)];
            //条件语句
            NSMutableString *whereSql;
            
            //判断是否有key
            if (key && ![key isEqualToString:@""]) {
                
               whereSql = [NSMutableString stringWithFormat:@" where %@=%@",key,[model valueForKey:key]];
                
            }else{
            
                whereSql = [NSMutableString stringWithFormat:@""];
            }
            
            
            //获取属性键值对
            NSDictionary *members = [model allMembers];
            
            //子model数组
            NSMutableArray *childModels = [[NSMutableArray alloc] init];
            
            
            //需要更新的值
            NSMutableArray *values = [[NSMutableArray alloc] init];
            
            //遍历model的属性
            for (NSInteger i = 0; i < members.allKeys.count; i ++) {
                
                //获取键
                NSString *member = members.allKeys[i];
                
                if (![member isEqualToString:key]) {
                    
                    
                    id data = [self returnContent:model withKey:members.allKeys[i]];
                    
                    //
                    NSInteger type = [model.allMembers[members.allKeys[i]] integerValue];
                    
                    switch (type) {
                        case DBDataTypeMODEL:
                            
                            if (data)  [childModels addObject:data];
                            
                            //最后一位是model，去除逗号
                            if (i == members.allKeys.count - 1 && [sql hasSuffix:@","]) {
                                
                                [sql deleteCharactersInRange:NSMakeRange([sql length] - 1, 1)];
                            }
                            
                            break;
                            case DBDataTypeERROR:
                            break;
                            case DBDataTypeINT:
                            case DBDataTypeBOOL:
                            case DBDataTypeTEXT:
                            //基本类型（text，int，bool）
                            [values addObject:data]; //如果存在，添加到sql语句
                            [sql appendFormat:@"'%@'=?",member];
                            if (i != members.allKeys.count - 1) {
                                //不是最后一个元素，添加“，”
                                [sql appendString:@","];
                            }
                            break;
                        default:
                            break;
                    }
                }
                
            }
            
            NSError *error;
            NSString * updateSql = [NSString stringWithFormat:@"%@%@",sql,whereSql];
            BOOL res = [_db executeUpdate:updateSql values:values error:&error];
            
            if (!res) {
                NSLog(@"更新失败");
                NSLog(@"%@",error);
            }else{
                
                NSLog(@"更新成功");
                
            }
            //枚举遍历
            [childModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                //递归
                [self updateData:obj mainKey:nil];
            }];
            [_db close];
            
        }
        
    
    
}

#pragma mark - 查询

/**
 *  查询
 *
 *  @param modelName 表名
 *
 *  @return 查询数组
 */
- (id) searchData:(NSString *)modelName {

    if (![_db open]) {
        
    }else{
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",modelName];
        FMResultSet *rs = [_db executeQuery:sql];
        NSMutableArray *rsArr = [[NSMutableArray alloc] init];
        while ([rs next]) {
            NSDictionary *dic = [self returnDicWithClassName:modelName];
            [rsArr addObject:[self setupModelWithDic:dic result:rs withClassName:modelName]];
        }
        [_db close];
        return rsArr;
    }
    return nil;
}

/**
 *  resultSet转换
 *
 *  @param dic       model属性字典
 *  @param rs        FMResultSet
 *  @param className 表名
 *
 *  @return model
 */
-(id) setupModelWithDic:(NSDictionary *)dic result:(FMResultSet *)rs withClassName:(NSString *)className {

    //获取model
    id model = [[NSClassFromString(className) alloc] init];
    
    for (NSInteger i = 0; i < dic.allKeys.count; i ++) {
        NSString *key = dic.allKeys[i];
        
        switch ([dic[key] integerValue]) {
            case DBDataTypeMODEL:
                //找出表名
                
              NSLog(@"%@",NSStringFromClass([model class]));
                
                
                break;
                
                case DBDataTypeERROR:
                break;
                
                case DBDataTypeBOOL:
                
                [model setValue:@([rs boolForColumn:key]) forKey:key];
                break;
                
                case DBDataTypeINT:
                
                [model setValue:@([rs intForColumn:key]) forKey:key];
                break;
                
                case DBDataTypeTEXT:
                
                [model setValue:[rs stringForColumn:key] forKey:key];
                
                break;
                
            default:
                break;
        }
        
    }
    return model;
}


#pragma mark - 删除

- (void) removeAll:(NSString *) tableName {

    if (![_db open]) {
        
    }else{
    
        //sql语句
        NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ ",tableName];
        
        
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            NSLog(@"删除失败");
        }else{
        
            NSLog(@"删除成功");
        }
        [_db close];
    }
}
#pragma  - 创建表
/**
 *  创建表
 *
 *  @param tableName 表名
 *  @param db        db
 */
- (void) createTable:(NSString *)tableName fmdb:(FMDatabase *)db {

    //获取所有成员键值对
    NSDictionary *members = [self returnDicWithClassName:tableName];
    
    //sql创建表语句
    NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ",tableName];
    NSMutableString *sqlMember = [[NSMutableString alloc] initWithString:@"(id INTEGER PRIMARY KEY AUTOINCREMENT"];
    
    
    for (NSInteger i = 0; i < members.allKeys.count; i ++) {
        NSString *member = members.allKeys[i];
        NSInteger type = [members[member] integerValue];
        switch (type) {
            case DBDataTypeMODEL:
                //如果是model,不添加字段
                case DBDataTypeERROR:
                break;
                case DBDataTypeTEXT:
                case DBDataTypeINT:
                case DBDataTypeBOOL:
                //基本类型
                [sqlMember appendString:[NSString stringWithFormat:@",%@ %@",member,[self returnType:[members[member] integerValue]]]];
                break;
            default:
                break;
        }

        if (i == members.allKeys.count - 1) {
            [sqlMember appendString:@")"];
        }
    }
    
    BOOL res = [db executeUpdate:[NSString stringWithFormat:@"%@%@",sqlCreateTable,sqlMember]];
    
    if (!res) {
        
        NSLog(@"error when creating db table");
    }else{
        
        NSLog(@"success to creating db table");

    }
    
   
}

#pragma mark - 辅助方法

/**
 *  根据model获取值
 */
- (id) returnContent:(RuntimeModel *)model withKey:(NSString *)key {
    return [model valueForKey:key];
}

/**
 *  className转成字典
 *
 *  @param className 类名
 *
 *  @return 访问类方法，返回属性键值对
 */
- (NSDictionary *) returnDicWithClassName :(NSString *)className {

    //获取对象，发送消息
    id model = [[NSClassFromString(className) alloc] init];
    SEL sel = NSSelectorFromString(@"allMembers");
    
    //消除arc下的警告
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([model respondsToSelector:sel]) {
        //响应方法
        return [model performSelector:sel];
    }else{
    
        return nil;
    }
     #pragma clang diagnostic pop
    
}

/**
 *  枚举换sqlite类型
 *
 *  @param type DBDataType
 *
 *  @return sqlite类型
 */
- (NSString *) returnType:(DBDataType) type {

    switch (type) {
        case DBDataTypeBOOL:
            return @"BOOL";
            break;
            
            case DBDataTypeINT:
            return @"INTEGER";
            break;
            
            case DBDataTypeTEXT:
            return @"TEXT";
            break;
        default:
            break;
    }
    return nil;
}
@end
