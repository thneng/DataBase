//
//  TestModel2.h
//  baoshanTest
//
//  Created by baoshan on 16/8/19.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import "RuntimeModel.h"
#import "TestModel3.h"
@interface TestModel2 : RuntimeModel
@property (nonatomic,strong)TestModel3 *testmodel3;

@property (nonatomic,copy)NSString *filmId;

@property (nonatomic,copy)NSString *filmType;

@property (nonatomic,copy)NSString *filmRegion;

@property (nonatomic,copy)NSString *filmTime;

@property (nonatomic,copy)NSString *filmLong;


@end
