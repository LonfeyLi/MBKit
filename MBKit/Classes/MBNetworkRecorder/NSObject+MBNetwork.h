//
//  NSObject+MBNetwork.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
NSArray<Class> *MBGetAllSubclasses(_Nullable Class cls, BOOL includeSelf);
@interface NSObject (MBNetwork)
@property (nonatomic, readonly, class) NSArray<Class> *mb_allSubclasses;
@end

NS_ASSUME_NONNULL_END

