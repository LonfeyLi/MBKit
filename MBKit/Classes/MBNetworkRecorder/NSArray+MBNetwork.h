//
//  NSArray+MBNetwork.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSArray<T> (MBNetwork)
- (__kindof NSArray *)mb_mapped:(id(^)(T obj, NSUInteger idx))mapFunc;
- (instancetype)mb_filtered:(BOOL(^)(T obj, NSUInteger idx))filterFunc;
@end

NS_ASSUME_NONNULL_END

