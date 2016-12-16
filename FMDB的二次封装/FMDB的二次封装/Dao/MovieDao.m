//
//  MovieDao.m
//  baoshanTest
//
//  Created by baoshan on 16/8/26.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import "MovieDao.h"
#import "DbManager.h"
#import "TestModel2.h"
#import "TestModel3.h"

static NSString *const MOVIE_TABLE_NAME = @"movie";
static NSString *const MOVIE_ACTOR_TABLE_NAME = @"movie_actor";

@implementation MovieDao

/**
 *  保存数据
 */
+ (void)saveMovie:(TestModel2 *)model{

    [[DbManager getInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:MOVIE_TABLE_NAME]) {
            [self createMovieTable:db];
        }
        
        //新增或替换表信息
        [db executeInsertOrReplaceInTable:MOVIE_TABLE_NAME
                  withParameterDictionary:@{@"film_id" : NULLABLE(model.filmId),
                                            @"film_type" : NULLABLE(model.filmType),
                                            @"film_region" : NULLABLE(model.filmRegion),
                                            @"film_time" : NULLABLE(model.filmTime),
                                            @"film_long" : NULLABLE(model.filmLong)}];
        
        //model 中有嵌套，建子表
        [self createMoviewActorTable:db];
        
        //先删除对应的信息
        [db executeUpdate:@"delete from movie_actor where film_id = ?" withArgumentsInArray:@[model.filmId]];
        
        //写入
        [db executeInsertOrReplaceInTable:MOVIE_ACTOR_TABLE_NAME withParameterDictionary:@{@"film_id" : NULLABLE(model.testmodel3.filmId),
                                                                                          @"actor_id" : NULLABLE(model.testmodel3.actorId),
                                                                                          @"actor_name" : NULLABLE(model.testmodel3.actorName),
                                                                                          @"actor_age" : NULLABLE(model.testmodel3.actorAge),
                                                                                           @"headImgUrl" : NULLABLE(model.testmodel3.headImgUrl)}];
        
    }];
}

/**
 *  读表
 *
 *  @param completion 回调 model
 */
+ (void)loadMovieCompletion:(void (^)(TestModel2 *model))completion{

    [[DbManager getInstance].dbQueue inDatabase:^(FMDatabase *db) {
       
        
        //建表
        [self createMovieTable:db];
        
        
        //sql语句
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",MOVIE_TABLE_NAME];
        FMResultSet *rs = [db executeQuery:sql];
        
        //将查询结果放在 model 中
        TestModel2 *testModel2;
        
        while ([rs next]) {
            
            testModel2 = [[TestModel2 alloc] init];
            testModel2.filmId = [rs stringForColumn:@"film_id"];
            testModel2.filmType = [rs stringForColumn:@"film_type"];
            testModel2.filmRegion = [rs stringForColumn:@"film_region"];
            testModel2.filmTime = [rs stringForColumn:@"film_time"];
            testModel2.filmLong = [rs stringForColumn:@"film_long"];
        }
        //关闭连接
        [rs close];
        
        //建表
        [self createMoviewActorTable:db];
        
        rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ where film_id = ?",MOVIE_ACTOR_TABLE_NAME]withArgumentsInArray:@[testModel2.filmId]];
        TestModel3 *model3;
        while ([rs next]) {
            //给model赋值
            model3 = [[TestModel3 alloc] init];
            model3.actorId = [rs stringForColumn:@"actor_id"];
            model3.actorName = [rs stringForColumn:@"actor_name"];
            model3.actorAge = [rs stringForColumn:@"actor_age"];
            model3.filmId = [rs stringForColumn:@"film_id"];
            model3.headImgUrl = [rs stringForColumn:@"headimgurl"];
        }
        testModel2.testmodel3 = model3;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(testModel2);
            }
        });
    }];
}

/**
 *  根据电影id删除电影
 *
 *  @param film_id     查询条件
 *  @param complection 成功回调
 */
+ (void)deleteMovieByFilm_id:(NSString *) film_id complection:(void(^)(void)) complection{

    [[DbManager getInstance].dbQueue inDatabase:^(FMDatabase *db) {
       
        //检查表
        [self createMovieTable:db];
        
        //sql语句
        NSString *sql;
        NSString *subSql;
        //根据是否有film_id判断删除什么
        if (![film_id isEqualToString:@""] && !film_id) {
           
            sql = [NSString stringWithFormat:@"DELETE FROM %@",MOVIE_TABLE_NAME];
            subSql = [NSString stringWithFormat:@"DELE FROM %@",MOVIE_ACTOR_TABLE_NAME];
        }else{
            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE film_id=?",MOVIE_TABLE_NAME];
            subSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE film_id=?",MOVIE_ACTOR_TABLE_NAME];
        }
        
        [db executeUpdate:sql withArgumentsInArray:@[film_id]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complection) {
                complection();
            }
        });
    }];
}

/**
 *  删除表
 *
 *  @param complection 成功回调
 */
+ (void)deleteMovieComplection:(void(^)(void)) complection{


    [self deleteMovieByFilm_id:nil complection:^{
        if (complection) {
            complection();
        }
    }];
}
/**
 *  创建movieActorTable
 */
+ (void)createMoviewActorTable:(FMDatabase *)db{

    if (![db tableExists:MOVIE_ACTOR_TABLE_NAME]) {
#if 0
        NSDictionary *table = @{@"film_id" : @"TEXT ",
                                @"actor_id" : @"TEXT PRIMARY KEY",
                                @"actor_name" : @"TEXT",
                                @"actor_age" : @"TEXT",
                                @"headImgUrl" : @"TEXT"};
        
        [db createTable:MOVIE_ACTOR_TABLE_NAME columns:table];
#else
        //表外键约束，级联主表删除更新
        NSString *sql = [NSString stringWithFormat:@"create table %@(film_id TEXT,actor_id TEXT PRIMARY KEY,actor_name TEXT,actor_age TEXT,headImgUrl TEXT,CONSTRAINT %@ FOREIGN KEY(film_id) REFERENCES %@(film_id) ON DELETE CASCADE ON UPDATE CASCADE)",MOVIE_ACTOR_TABLE_NAME,MOVIE_ACTOR_TABLE_NAME,MOVIE_TABLE_NAME];

        [db executeUpdate:sql];
        [db executeUpdate:@"PRAGMA foreign_keys = ON"];
#endif
    }
}

/**
 *  创建movieTable
 */
+ (void)createMovieTable:(FMDatabase *)db{

    if (![db tableExists:MOVIE_TABLE_NAME]) {
        NSDictionary *table = @{@"film_id" : @"TEXT PRIMARY KEY",
                                @"film_type" : @"TEXT",
                                @"film_region" : @"TEXT",
                                @"film_time" : @"TEXT",
                                @"film_long" : @"TEXT"
                                };
        [db createTable:MOVIE_TABLE_NAME columns:table];
    }
}
@end
