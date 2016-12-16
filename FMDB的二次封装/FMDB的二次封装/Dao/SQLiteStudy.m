//
//  SQLiteStudy.m
//  FMDB的二次封装
//
//  Created by baoshan on 16/9/7.
//
//

#import "SQLiteStudy.h"
#import "DbManager.h"

/**
 *  SQLite 常用语法，参考资料：http://www.runoob.com/sqlite/sqlite-tutorial.html
 */

@implementation SQLiteStudy{
    
    __block  FMDatabase *_db;
}

//表名
static NSString *const TABLE_NAME_COMPANY = @"COMPANY";
static NSString *const TABLE_NAME_COMPANY_BKP = @"COMPANY_BKP";
static NSString *const TABLE_NAME_DEPARTMENT = @"DEPARTMENT";
static NSString *const TABLE_NAME_ADULT = @"ADULT";

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configDb];
    }
    return self;
}
/**
 *  方便测试
 */
- (void)configDb{
    
    [[DbManager getInstance].dbQueue inDatabase:^(FMDatabase *db) {
        
        _db = db;
        
    }];
    
}
#pragma mark - 插入数据测试
- (void)insertData{
    
    NSString *sql = @"INSERT INTO COMPANY (NAME,AGE,ADDRESS,SALARY) VALUES ('Paul', 34, 'California', 20000.00)";
    [_db executeUpdate:sql];
}
#pragma mark - ==============    创建   ============
#pragma mark  SQLite 约束

/**
 *  NOT NULL 约束：确保某列不能有 NULL 值。
 *  DEFAULT 约束：当某列没有指定值时，为该列提供默认值。
 *  UNIQUE 约束：确保某列中的所有值是不同的。
 *  PRIMARY Key 约束：唯一标识数据库表中的各行/记录。
 *  CHECK 约束：CHECK 约束确保某列中的所有值满足一定条件。
 *  AUTOINCREMENT ： 自动递增
 */
- (void)createConstraintTable{
    
    //COMPANY 表
    if (![_db tableExists:TABLE_NAME_COMPANY]) {
        
        NSDictionary *table = @{@"ID" : @"INTEGER PRIMARY KEY AUTOINCREMENT",
                                @"NAME" : @"TEXT NOT NULL",
                                @"AGE" : @"INT NOT NULL",
                                @"ADDRESS" : @"CHAR(50) DEFAULT 'shenzhen'",
                                @"SALARY" : @"REAL CHECK(SALARY >0)"
                                };
        [_db createTable:TABLE_NAME_COMPANY columns:table];
    }
    
    //DEPARTMENT 表
    if (![_db tableExists:TABLE_NAME_DEPARTMENT]) {
        NSDictionary *table = @{@"ID" : @"INT PRIMARY KEY NOT NULL",
                                @"DEPT" : @"CHAR(50) NOT NULL",
                                @"EMP_ID" : @"INT NOT NULL"
                                };
        [_db createTable:TABLE_NAME_DEPARTMENT columns:table];
    }
    
    //ADULT 表
    if (![_db tableExists:TABLE_NAME_ADULT]) {
        NSDictionary *table = @{@"EMP_ID" : @"INT NOT NULL",
                                @"ENTRYDATE" : @"TEXT NOT NULL"
                                };
        [_db createTable:TABLE_NAME_ADULT columns:table];
        //触发器
        [self createTrigger];
    }
    
    //COMPANY_BKP 表
    if (![_db tableExists:TABLE_NAME_COMPANY_BKP]) {
        NSDictionary *table = @{@"ID" : @"INTEGER PRIMARY KEY AUTOINCREMENT",
                                @"NAME" : @"TEXT NOT NULL",
                                @"AGE" : @"INT NOT NULL",
                                @"ADDRESS" : @"CHAR(50) DEFAULT 'shenzhen'",
                                @"SALARY" : @"REAL CHECK(SALARY >0)"
                                };
        [_db createTable:TABLE_NAME_COMPANY_BKP columns:table];
    }
}


#pragma mark -  ===============    其他   ============
#pragma mark  触发器

/**
 *  触发器是数据库的回调函数，它会自动执行/指定的数据库事件发生时调用,
 *   比如用在需要对某些表的操作之后对相应的表增删改数据
 */
- (void)createTrigger{
    
#if 0
    //删除触发器
    NSString *dropSql = @"DROP TRIGGER audit_log";
    [_db executeUpdate:dropSql];
#endif
    NSString *sql = [NSString stringWithFormat:@"CREATE TRIGGER audit_log AFTER INSERT ON COMPANY BEGIN INSERT INTO ADULT(EMP_ID, ENTRYDATE) VALUES (new.ID, datetime('now')); END"];
    [_db executeUpdate:sql];
    
    //插入数据
    //    [self performSelector:@selector(insertData) withObject:nil afterDelay:1.0f];
}

#pragma mark  索引、视图、事务
/**
 *  客户端应该不需要考虑使用索引、视图
 *  索引：索引只有在数据量大的表中才会使用
 *  视图: 视图（View）是一种虚表
 *  事务：处理大量数据的时候使用
 [[DbManager getInstance].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
 http://www.runoob.com/sqlite/sqlite-transaction.html
 }]
 */


#pragma mark  ALTER

/**
 *  重命名表，还可以在已有的表中添加额外的列
 */
- (void)renameTableOrInsertColumn{
#if 1
    //重命名表
    NSString *sql = @"ALTER TABLE COMPANY RENAME TO OLD_COMPANY";
#else
    //添加列
    NSString *sql = @"ALTER TABLE COMPANY ADD COLUMN SEX char(1)";
#endif
    [_db executeUpdate:sql];
}


#pragma mark - =============   查询  =============

#pragma mark  SQLite Joins
/**
 *  交叉连接 - CROSS JOIN
 *  内连接 - INNER JOIN
 *  外连接 - OUTER JOIN
 */
- (void)searchJoins{
#if 0
    //CROSS JOIN
    NSString *sql = [NSString stringWithFormat:@"SELETE EMP_ID,NAME,DEPT FROM COMPANY CROSS JOIN DEPARTMENT"];
    
#elif 1
    //INNER JOIN
    NSString *sql = [NSString stringWithFormat:@"SELECT EMP_ID, NAME, DEPT FROM COMPANY INNER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID"];
#else
    //OUTER JOIN
    NSString *sql = [NSString stringWithFormat:@"SELECT EMP_ID, NAME, DEPT FROM COMPANY LEFT OUTER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID"];
#endif
    FMResultSet *resultSet = [_db executeQuery:sql];
    while ([resultSet next]) {
        NSLog(@"EMP_ID = %d",[resultSet intForColumn:@"EMP_ID"]);
        NSLog(@"NAME = %@", [resultSet stringForColumn:@"NAME"]);
        NSLog(@"DEPT = %@", [resultSet stringForColumn:@"DEPT"]);
    }
    [resultSet close];
}

#pragma mark  SQLite UNIONS子句
/**
 *  SQLite的 UNION 子句/运算符用于合并两个或多个 SELECT 语句的结果
 */
- (void)searchUnion{
#if 0
    //UNION 重复行不返回
    NSString *sql = [NSString stringWithFormat:@"SELECT EMP_ID, NAME, DEPT FROM COMPANY INNER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID UNION SELECT EMP_ID, NAME, DEPT FROM COMPANY LEFT OUTER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID"];
#else
    //UNION ALL 把重复行也返回
    NSString *sql = [NSString stringWithFormat:@"SELECT EMP_ID, NAME, DEPT FROM COMPANY INNER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID UNION ALL SELECT EMP_ID, NAME, DEPT FROM COMPANY LEFT OUTER JOIN DEPARTMENT ON COMPANY.ID = DEPARTMENT.EMP_ID"];
#endif
    FMResultSet *resultSet = [_db executeQuery:sql];
    while ([resultSet next]) {
        NSLog(@"EMP_ID = %d",[resultSet intForColumn:@"EMP_ID"]);
        NSLog(@"NAME = %@", [resultSet stringForColumn:@"NAME"]);
        NSLog(@"DEPT = %@", [resultSet stringForColumn:@"DEPT"]);
    }
    [resultSet close];
}
#pragma mark  子查询
/**
 *  子查询可以与 SELECT、INSERT、UPDATE 和 DELETE 语句一起使用，可伴随着使用运算符如 =、<、>、>=、<=、IN、BETWEEN 等。
 *  子查询必须用括号括起来。
 *  子查询在 SELECT 子句中只能有一个列，除非在主查询中有多列，与子查询的所选列进行比较。
 *  ORDER BY 不能用在子查询中，虽然主查询可以使用 ORDER BY。可以在子查询中使用 GROUP BY，功能与 ORDER BY 相同。
 *  子查询返回多于一行，只能与多值运算符一起使用，如 IN 运算符。
 *  BETWEEN 运算符不能与子查询一起使用，但是，BETWEEN 可在子查询内使用。
 */

- (void)subquery{
#if 0
    NSString *selectSQL = @"SELECT *FROM COMPANY WHERE ID IN (SELECT ID FROM COMPANY WHERE SALARY > 45000)";
    FMResultSet *resultSet = [_db executeQuery:selectSQL];
    while ([resultSet next]) {
        NSLog(@"EMP_ID = %d",[resultSet intForColumn:@"EMP_ID"]);
        NSLog(@"NAME = %@", [resultSet stringForColumn:@"NAME"]);
        NSLog(@"DEPT = %@", [resultSet stringForColumn:@"DEPT"]);
    }
    [resultSet close];
#elif 1
    NSString *insertSQL = @"INSERT INTO COMPANY_BKP SELECT * FROM COMPANY WHERE ID IN (SELECT ID FROM COMPANY)";//整个 COMPANY 表复制到 COMPANY_BKP
    [_db executeUpdate:insertSQL];
#elif 0
    NSString *updateSQL = @"UPDATE COMPANY SET SALARY = SALARY * 0.50 WHERE AGE IN (SELECT AGE FROM COMPANY_BKP WHERE AGE >= 27 )";
    [_db executeUpdate:updateSQL];
#else
    NSString *deleteSQL = @"DELETE FROM COMPANY WHERE AGE IN (SELECT AGE FROM COMPANY_BKP WHERE AGE > 27 )";
    [_db executeUpdate:deleteSQL];
    
#endif
}


#pragma mark  SQLite函数
- (void)sqlFunction{
#if 0
    //计算一个数据库表中的行数
    NSString *countSQL = @"SELECT count(*) FROM COMPANY";
    
    //某列的最大值
    NSString *maxSQL = @"SELECT max(salary) FROM COMPANY";
    
    //某列的最小值
    NSString *minSQL = @"SELECT min(salary) FROM COMPANY";
    
    //某列的平均值
    NSString *avgSQL = @"SELECT avg(salary) FROM COMPANY";
    
    //数值列计算总和
    NSString *sumSQL = @"SELECT sum(salary) FROM COMPANY";
    
    //返回随机数
    NSString *randomSQL = @"SELECT random() AS Random";
    
    //参数绝对值
    NSString *absSQL = @"SELECT abs(5), abs(-15), abs(NULL), abs(0), abs(\"ABC\")";//大写字母用双引号
    
    //字符串转换为小写字母
    NSString *lowerSQL = @"SELECT lower(name) FROM COMPANY";
    
    //返回字符串长度
    NSString *lengthSQL = @"SELECT name, length(name) FROM COMPANY";
#endif
    
    
}

#pragma mark  SQLite LIKE 关键字
/**
 *  SQLite 的 LIKE 运算符是用来匹配通配符指定模式的文本值。如果搜索表达式与模式表达式匹配，LIKE 运算符将返回真（true），也就是 1。这里有两个通配符与 LIKE 运算符一起使用：
 *  百分号 （%）
 *  下划线 （_）
 */
- (void)searchLike_SQL{
#if 0
    NSString *sql1 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '200%'";//查找以 200 开头的任意值
    NSString *sql2 = @"SELECT * FROM COMPANY WHERE AGE LIKE '%200%'";//任意位置包含 200 的任意值
    NSString *sql3 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '_00%'";//第二位和第三位为 00 的任意值
    NSString *sql4 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '2_%_%'";//查找以 2 开头，且长度至少为 3 个字符的任意值
    NSString *sql5 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '%2'";//以 2 结尾的任意值
    NSString *sql6 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '_2%3'"; //查找第二位为 2，且以 3 结尾的任意值
    NSString *sql7 = @"SELECT * FROM COMPANY WHERE SALARY LIKE '2___3'";//找长度为 5 位数，且以 2 开头以 3 结尾的任意值
#endif
}

/**
 *   GLOB 运算符是用来匹配通配符指定模式的文本值
 *  与 LIKE 运算符不同的是，GLOB 是大小写敏感的
 *  星号（*）代表零个、一个或多个数字或字符。问号（?）代表一个单一的数字或字符。这些符号可以被组合使用。
 */
#pragma  SQLite GLOB 子句
- (void)searchGLOB_SQL{
#if 0
    NSString *sql1 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '200*'";//查找以 200 开头的任意值
    NSString *sql2 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '*200*'";//查找任意位置包含 200 的任意值
    NSString *sql3 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '?00*'";//查找第二位和第三位为 00 的任意值
    NSString *sql4 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '2??'";//查找以 2 开头，且长度至少为 3 个字符的任意值
    NSString *sql5 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '*2'";//查找以 2 结尾的任意值
    NSString *sql6 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '?2*3'";//查找第二位为 2，且以 3 结尾的任意值
    NSString *sql7 = @"SELECT * FROM COMPANY WHERE SALARY GLOB '2???3'";//查找长度为 5 位数，且以 2 开头以 3 结尾的任意值
#endif
}

#pragma mark SQLite LIMIT 字句
/**
 *   LIMIT 子句用于限制由 SELECT 语句返回的数据数量
 */
- (void)searchLIMIT_SQL{
#if 0
    NSString *sql1 = @"SELECT * FROM COMPANY WHERE SALARY LIMIT 6";
    NSString *sql2 = @"SELECT * FROM COMPANY WHERE SALARY LIMIT 3 OFFSET 2";//从第二个开始取，取3个
#endif
}

#pragma mark SQLite Order By

/**
 *  ORDER BY 子句是用来基于一个或多个列按升序或降序顺序排列数据
 */
- (void)searchORDER_BY_SQL{
#if 0
    //升序
    NSString *sql = @"SELECT * FROM COMPANY ORDER BY SALARY ASC";
    NSString *descSql = @"SELECT * FROM COMPANY ORDER BY SALARY DESC";
#endif
    
}

#pragma mark SQLite group by
/**
 *  GROUP BY 子句用于与 SELECT 语句一起使用，来对相同的数据进行分组。
 *  GROUP BY 子句放在 WHERE 子句之后，放在 ORDER BY 子句之前
 */
- (void)searchGROUP_BY_SQL{
#if 0
    NSString *sql = @"SELECT NAME, SUM(SALARY) FROM COMPANY GROUP BY NAME ORDER BY NAME DESC";
#endif
}

#pragma mark SQLite having

/**
 *  HAVING 子句允许指定条件来过滤将出现在最终结果中的分组结果
 */
- (void)searchHAVING_SQL{
#if 0
    NSString *sql = @"SELECT * FROM COMPANY GROUP BY name HAVING count(name) > 2";
#endif
}

#pragma mark SQLite Having

/**
 *  消除所有重复的记录，并只获取唯一一次记录
 */
- (void)searchDISTINCT_SQL{
#if 0
    NSString *sql = @"SELECT DISTINCT name FROM COMPANY";
#endif
}

#pragma mark SQLite AND/OR

- (void)searchAN_OR_SQL{
#if 0
    NSString *orSql = @"SELECT * FROM COMPANY WHERE AGE >= 25 OR SALARY >= 65000";
    NSString *andSql = @"SELECT * FROM COMPANY WHERE AGE >= 25 and SALARY >= 65000";
#endif
}
@end
