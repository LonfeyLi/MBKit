//
//  NSArray+MBNetwork.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import "NSArray+MBNetwork.h"

@implementation NSArray (MBNetwork)
+ (instancetype)mb_mapped:(id<NSFastEnumeration>)collection block:(id(^)(id obj, NSUInteger idx))mapFunc {
    NSMutableArray *array = [NSMutableArray new];
    NSInteger idx = 0;
    for (id obj in collection) {
        id ret = mapFunc(obj, idx++);
        if (ret) {
            [array addObject:ret];
        }
    }

    // For performance reasons, don't copy large arrays
    if (array.count < 2048) {
        return array.copy;
    }

    return array;
}
- (__kindof NSArray *)mb_mapped:(id (^)(id, NSUInteger))mapFunc {
    NSMutableArray *map = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id ret = mapFunc(obj, idx);
        if (ret) {
            [map addObject:ret];
        }
    }];

    if (self.count < 2048 && ![[self class] isSubclassOfClass:[NSMutableArray class]]) {
        return map.copy;
    }

    return map;
}

- (NSArray *)mb_filtered:(BOOL (^)(id, NSUInteger))filterFunc {
    return [self mb_mapped:^id(id obj, NSUInteger idx) {
        return filterFunc(obj, idx) ? obj : nil;
    }];
}

@end

#endif
