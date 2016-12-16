//
//  DbManager.h
//  baoshanTest
//
//  Created by baoshan on 16/7/21.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabase+Mapping.h"


#define NULLABLE(value) (value != nil ? value : [NSNull null])
@interface DbManager : NSObject

@property (nonatomic,strong,readonly)FMDatabaseQueue *dbQueue;

/**
 *  单例
 */
+ (instancetype)getInstance;

@end
