//
//  KKPAPIModel.m
//  KKPKit
//
//  Created by 刘特风 on 16/1/8.
//  Copyright © 2016年 kakapo. All rights reserved.
//

#import "KKPAPIModel.h"
#import <objc/runtime.h>

@implementation KKPAPIModel

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [[self class] classPropsForClassHierarchy:[self class] onDictionary:dict];
    
    for (NSString *key in dict.allKeys) {
        NSString *path = key;
        if ([path hasSuffix:@"_"]) {
            path = [path substringToIndex:path.length - 1];
        }
        if (self.pathName) {
            [self setValue:[self.pathName stringByAppendingString:path] forKey:key];
        } else {
            [self setValue:path forKey:key];
        }
    }
    
    return self;
    
}

+ (NSDictionary *)classPropsForClassHierarchy:(Class)klass
                                 onDictionary:(NSMutableDictionary *)results
{
    if (NULL == klass) {
        return nil;
    }
    
    if ([NSObject class] == klass) {
        return [NSDictionary dictionaryWithDictionary:results];
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = getPropertyType(property);
        if(propName && propType) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            results[propertyName] = propertyType;
        }
    }
    free(properties);
    
    //go for the superclass
    return [self classPropsForClassHierarchy:[klass superclass] onDictionary:results];
    
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1
                                                      length:strlen(attribute) - 1
                                                    encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3
                                                      length:strlen(attribute) - 4
                                                    encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}


@end
