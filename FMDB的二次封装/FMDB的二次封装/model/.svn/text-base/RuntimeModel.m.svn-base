//
//  RuntimeModel.m
//  baoshanTest
//
//  Created by baoshan on 16/6/22.
//  Copyright © 2016年 Kairu. All rights reserved.
//

#import "RuntimeModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TestModel.h"

@implementation RuntimeModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+(id)objectWithKeyValues:(NSDictionary *)aDictionary{

    id obj= [[self alloc]init];
    
    for (NSString *key in aDictionary.allKeys) {
        
        id value = aDictionary[key];
        
        //判断当前属性是不是model
        objc_property_t property = class_getProperty(self, key.UTF8String);
        
        unsigned int outCount = 0;
        objc_property_attribute_t *attrbutelist = property_copyAttributeList(property, &outCount);
        objc_property_attribute_t attribute = attrbutelist[0];
        
        NSString *typeString = [NSString stringWithUTF8String:attribute.value];
        if ([typeString isEqualToString:@"@\"RuntimeModel\""]) {
            value = [self objectWithKeyValues:value];
        }
        
        //生成setter，用objc_msgSend调用
        NSString *methodName = [NSString stringWithFormat:@"set%@%@:",[key substringToIndex:1].uppercaseString,[key substringFromIndex:1]];
        SEL setter = sel_registerName(methodName.UTF8String);
        if ([obj respondsToSelector:setter]) {
            ((void (*) (id,SEL,id)) objc_msgSend) (obj,setter,value);
           
        }
    }
    return obj;
}






//模型转字典
-(NSDictionary *)keyValuesWithObject{
    unsigned int outCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = propertyList[i];
        
        //生成getter方法，并用objc_msgSend调用
        const char *propertyName = property_getName(property);
        SEL getter = sel_registerName(propertyName);
        if ([self respondsToSelector:getter]) {
            id value = ((id (*) (id,SEL)) objc_msgSend) (self,getter);
            
            /*判断当前属性是不是Model*/
            if ([value isKindOfClass:[self class]] && value) {
                value = [value keyValuesWithObject];
            }
            /**********************/
            
            if (value) {
                NSString *key = [NSString stringWithUTF8String:propertyName];
                [dict setObject:value forKey:key];
            }
        }
        
    }
    free(propertyList);
    return dict;
}

- (NSDictionary *)allMembers {
    NSMutableDictionary * members = [[NSMutableDictionary alloc]init];
    
    unsigned int outCount, i;
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding] ;
        
        NSString *propertyClass = [[NSString alloc] initWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] ;
        [members setObject:@([self returnType:propertyClass]) forKey:propertyName];
    }
    
    free(properties);
    
    return [members copy];
}

- (DBDataType)returnType:(NSString *)T {
    if ([T hasPrefix:@"T@\"NSString\""]) {
        return DBDataTypeTEXT;
    } else if ([T hasPrefix:@"T@\""]) {
        return DBDataTypeMODEL;
    }else if ([T hasPrefix:@"TB"]) {
        return DBDataTypeBOOL;
    } else if ([T hasPrefix:@"Tq"]) {
        return DBDataTypeINT;
    }
    return DBDataTypeERROR;
}


@end
