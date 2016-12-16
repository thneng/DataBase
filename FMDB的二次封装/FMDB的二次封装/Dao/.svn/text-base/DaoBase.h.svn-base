//
//  DaoBase.h
//  baoshanTest
//
//  Created by baoshan on 16/8/17.
//  Copyright © 2016年 Kairu. All rights reserved.
//

/*
 粗略的把功能写了出来。但是还有很多需要修改和优化的地方，比如代码复用这块，并发处理这块，还有怎么嵌套查询这块，都需要大家给出建议
 */

#import "FMDB.h"

@class RuntimeModel;


@interface DaoBase : NSObject

@property (nonatomic,strong,readonly)FMDatabaseQueue *dbQueue;

/**
 *  单例
 */
+ (instancetype) getInstance;

/**
 *  储存
 */
- (void) saveData:(RuntimeModel *) model;

/**
 *  更新
 */
- (void) updateData:(RuntimeModel *) model;

/**
 *  查找
 */
- (id) searchData:(NSString *) modelName;

/**
 *  删除
 */
- (void) removeAll:(NSString *) tableName;
@end
