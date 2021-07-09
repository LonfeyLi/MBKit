//
//  NSObject+MBNetwork.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "NSObject+MBNetwork.h"
#import <objc/runtime.h>
NSArray<Class> *MBGetAllSubclasses(Class cls, BOOL includeSelf) {
    if (!cls) {
        return nil;
    }
    
    Class *buffer = NULL;
    
    int count, size;
    do {
        count  = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size   = objc_getClassList(buffer, count);
    } while (size != count);
    
    NSMutableArray *classes = [NSMutableArray new];
    if (includeSelf) {
        [classes addObject:cls];
    }
    
    for (int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while ((superclass = class_getSuperclass(superclass))) {
            if (superclass == cls) {
                [classes addObject:candidate];
                break;
            }
        }
    }
    
    free(buffer);
    return classes.copy;
    
}

@implementation NSObject (MBNetwork)

+ (NSArray *)mb_allSubclasses {
    return MBGetAllSubclasses(self, YES);
}

@end

