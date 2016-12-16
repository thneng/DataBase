//
//  MovieDao.h
//  baoshanTest
//
//  Created by baoshan on 16/8/26.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestModel2;

@interface MovieDao : NSObject

/**
 *  存数据
 *
 *  @param model 需要存的model
 */
+ (void)saveMovie:(TestModel2 *)model;

/**
 *  读数据
 *
 *  @param completion 成功回调model
 */
+ (void)loadMovieCompletion:(void (^)(TestModel2 *))completion;

/**
 *  删除数据
 *
 *  @param complection 事件成功回调
 */
+ (void)deleteMovieComplection:(void(^)(void)) complection;
@end
