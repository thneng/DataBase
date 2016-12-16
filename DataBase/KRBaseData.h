//
//  KRBaseData.h
//  SunshineHealthy
//
//  Created by James Hsu on 3/25/16.
//  Copyright © 2016 深圳市凯如科技有限公司. All rights reserved.
//

#import "FMDB/FMDB.h"

/**
 *  数据库用户表名称
 */
#define KRUserTableName @"usertablename"

/// 通讯录表
#define KRAddressBookName @"addressbookname"
/// 好友数据表
#define KRFriendsName   @"friendsname"

/// 全国省，直辖市数据表
#define KRAddressName   @"addressname"

/// 城市， 数据表
#define KRCityName      @"cityname"

/// 区 数据表
#define KRAreaName      @"areaname"
/// 健康档案列表
#define KRHealthyCaseName  @"healthycasename"

/// 微博发布数据表
#define KRWeiBoPostName     @"weiboPostName"


///**
// *   数据库学生表
// */
//#define KRStudentTableName @"studenttablename"

typedef NS_ENUM(NSUInteger, SQLtype) {
    SQLtypeInsert = 0,
    SQLtypeUpdate,
    SQLtypeQuery,
    SQLTypeDelete
};

typedef NS_ENUM(NSUInteger, KRErrorCode)
{
    KRErrorCodeUpdate = 1000,
    KRErrorCodeInsert,
    KRErrorCodeSearch,
    KRErrorCodeDelete,
    KRErrorCodeParameNULL
};

@class KRSQLModel;

/**
 * 数据实例
 */
typedef void(^FMDatabaseBlock)(BOOL ressult, KRSQLModel *sqlModel);

@interface KRBaseData : FMDatabaseQueue

@property (nonatomic, strong) KRSQLModel  * SqlModel;

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

/**
 *  查询数据库返回集合
 *
 *  @param name  数据库表名
 *  @param value  uid(当 uid 为空时返回当前所查询的表前十条数据, uid 有值返回 uid 等于 value 的数据)
 *
 *  @return  集合
 */
- (NSMutableArray *)queryTableWithName:(NSString *)name uidValue:(NSString *)value;

- (void)queryTableWithName:(NSString *)name
                  uidValue:(NSString *)value
                    listId:(NSString *)listId
                     limit:(NSInteger)limit
                  baseData:(FMDatabaseBlock)block;
/**
 查找数据
 
 @param name   数据库名
 @param parame 数组
 
 @return 集合
 */
- (NSDictionary *)searchTableName:(NSString *)name parame:(NSDictionary *)parame;

@end


@interface KRSQLModel : NSObject

@property (nonatomic, strong) NSArray   *results;

@property (nonatomic, assign) KRErrorCode   errorCode;

@property (nonatomic, strong) NSString  *errorMessage;

@end



