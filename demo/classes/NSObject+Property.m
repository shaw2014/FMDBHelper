//
//  NSObject+Property.m
//  FMDBOrmHandler
//
//  Created by caohuan on 14-07-05.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "NSObject+Property.h"

@implementation NSObject (Property)

- (NSArray *)propertyArray
{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList([self class], &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject: [NSString  stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return propertyArray;
}

- (NSDictionary *)convertDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *propertyList = [self propertyArray];
    for (NSString *key in propertyList) {
        SEL selector = NSSelectorFromString(key);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [self performSelector:selector];
        #pragma clang diagnostic pop
        
        if (value == nil) {
            value = [NSNull null];
        }
        [dict setObject:value forKey:key];
    }
    return dict;
}
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [self init];
    if(self)
        [self dictionaryForObject:dict];
    return self;
    
}
- (NSString *)className{
    return [NSString stringWithUTF8String:object_getClassName(self)];
}

- (BOOL)checkPropertyName:(NSString *)name
{
    unsigned int propCount, i;
    objc_property_t* properties = class_copyPropertyList([self class], &propCount);
    for (i = 0; i < propCount; i++) {
        objc_property_t prop = properties[i];
        const char *propName = property_getName(prop);
        if(propName) {
            NSString *_name = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            if ([name isEqualToString:_name]) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)dictionaryForObject:(NSDictionary*) dict
{
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        
        if (value==[NSNull null]) {
            continue;
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            id subObj = [self valueForKey:key];
            if (subObj)
                [subObj dictionaryForObject:value];
        }
        else{
             [self setValue:value forKeyPath:key];
        }
    }
}


#pragma mark - extra

//对象属性类型字典
- (NSDictionary *)propertyInfoDictionary
{
    u_int count;
    u_int superCount;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    objc_property_t *superProperties = class_copyPropertyList([self superclass], &superCount);
    
    NSMutableArray* propertyNameArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* propertyTypeArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        BOOL isSame = NO;
        
        NSString *propertyStr = [NSString stringWithUTF8String: propertyName];
        for(int j = 0; j < superCount; j++)
        {
            const char* superPropertyName = property_getName(superProperties[j]);
            
            NSString *superPropertyStr = [NSString stringWithUTF8String:superPropertyName];
            if([propertyStr isEqualToString:superPropertyStr])
            {
                isSame = YES;
            }
        }
        if(isSame)
        {
            continue;
        }
        
        NSString *attrStr = [[NSString alloc] initWithUTF8String:property_getAttributes(properties[i])];
        [propertyNameArray addObject:propertyStr];

        /*
         T@"NSString",C,N,V_nsstringField
         T@"NSDate",&,N,V_nsdateField
         T@"NSData",&,N,V_nsdataField
         T@"NSNumber",&,N,V_unreadCount
         TI,N,V_type
         TI,N,V_detailType
         Ti,N,V_intField
         Ti,N,V_NSIntegerField
         Tl,N,V_longField
         Tq,N,V_longlongField
         TL,N,V_unsignedLongField
         Tc,N,V_boolField
         Td,N,V_doubleField
         */
        
        //NSDate, NSData, NSString, NSNumber
        if ([attrStr hasPrefix:@"T@"]) {
            [propertyTypeArray addObject:[attrStr substringWithRange:NSMakeRange(3, [attrStr rangeOfString:@","].location-4)]];
        }
        //int , NSInteger
        else if ([attrStr hasPrefix:@"Ti"])
        {
            [propertyTypeArray addObject:@"int"];
        }
        //NSUInteger
        else if ([attrStr hasPrefix:@"TI"])
        {
            [propertyTypeArray addObject:@"int"];
        }
        //float
        else if ([attrStr hasPrefix:@"Tf"])
        {
            [propertyTypeArray addObject:@"float"];
        }
        //double
        else if([attrStr hasPrefix:@"Td"])
        {
            [propertyTypeArray addObject:@"double"];
        }
        //long
        else if([attrStr hasPrefix:@"Tl"])
        {
            [propertyTypeArray addObject:@"long"];
        }
        //long long
        else if ([attrStr hasPrefix:@"Tq"])
        {
            [propertyTypeArray addObject:@"long"];
        }
        //unsigned Long
        else if ([attrStr hasPrefix:@"TL"])
        {
            [propertyTypeArray addObject:@"long"];
        }
        //char
        else if ([attrStr hasPrefix:@"Tc"])
        {
            [propertyTypeArray addObject:@"char"];
        }
        //short
        else if([attrStr hasPrefix:@"Ts"])
        {
            [propertyTypeArray addObject:@"short"];
        }
    }
    
    free(properties);
    
    NSDictionary *propertyDictionary = @{@"name": propertyNameArray, @"type": propertyTypeArray};
    
    return propertyDictionary;
}

- (id)safetyValueForKey:(NSString*)key
{
    id value = [self valueForKey:key];
    if(value == nil)
    {
        return @"";
    }
    return value;
}

- (id)dangerousValueForKey:(NSString*)key
{
    SEL selector = NSSelectorFromString(key);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id value = [self performSelector:selector];
#pragma clang diagnostic pop
    
    if (value == nil) {
        value = @"";
    }
    return value;
}

#pragma mark- static method

const static NSString* normalTypesString = @"floatdoublelong";
const static NSString* intTypesString = @"intcharshort";
const static NSString* dateTypeString = @"NSDate";
const static NSString* blobTypeString = @"NSDataUIImage";

+ (NSString *)sqlliteTypeWithPropertyType:(NSString *)type
{
    if([intTypesString rangeOfString:type].location != NSNotFound){
        return K_SQLTYPE_Int;
    }
    if ([normalTypesString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Double;
    }
    if ([blobTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Blob;
    }
    if ([dateTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Date;
    }
    return K_SQLTYPE_Text;
}

@end
