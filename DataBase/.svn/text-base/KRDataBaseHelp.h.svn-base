//
//  KRDataBaseHelp.h
//  SunshineHealthy
//
//  Created by James Hsu on 3/25/16.
//  Copyright © 2016 深圳市凯如科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRBaseData.h"

@interface KRDataBaseHelp : NSObject

/// 单例
+ (KRDataBaseHelp *)sharedInstance;

/**
 *  数据库操作  异步
 *
 *  @param name   数据库表名
 *  @param parame 传入字典
 *  @param type   操作类型
 *  @param block  是否操作成功
 */
- (void)executeUpdateWithTableName:(NSString *)name
                          withData:(NSDictionary *)parame
                           SQLType:(SQLtype)type
                          baseData:(FMDatabaseBlock)block;

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
               baseData:(FMDatabaseBlock)block;

/**
 根据uid 查找

 @param uid 输入uid

 @return 字典
 */
- (NSDictionary *)searchUserWithUid:(NSString *)uid;

- (NSDictionary *)searchTableName:(NSString *)name withData:(NSDictionary *)parame;
@end
