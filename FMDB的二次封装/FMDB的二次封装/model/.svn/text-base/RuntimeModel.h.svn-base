//
//  RuntimeModel.h
//  baoshanTest
//
//  Created by baoshan on 16/6/22.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TestModel,TestModel2;

@interface RuntimeModel : NSObject

typedef NS_ENUM(NSInteger,DBDataType) {
    DBDataTypeBOOL = 0,
    DBDataTypeTEXT = 1,
    DBDataTypeINT  = 2,
    DBDataTypeMODEL = 3,
    DBDataTypeERROR = 999,
};


@property (nonatomic,copy)NSString *name;

@property (nonatomic,copy)NSString *stu_num;

@property (nonatomic,copy)NSString *address;

@property (nonatomic,copy)NSString *school_name;

@property (nonatomic,copy)NSString *phone_num;

@property (nonatomic,strong)TestModel *testModel;

@property (nonatomic,strong)TestModel2 *testModel2;

+(id)objectWithKeyValues:(NSDictionary *)aDictionary;

-(NSDictionary *)keyValuesWithObject;

- (NSDictionary *)allMembers;

@end
