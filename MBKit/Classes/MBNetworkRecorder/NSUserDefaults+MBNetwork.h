//
//  NSUserDefaults+MBNetwork.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef RELEASE

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kMBDefaultsNetworkHostBlacklistKey;
@interface NSUserDefaults (MBNetwork)

@property (nonatomic) NSArray<NSString *> *mb_networkHostBlacklist;
@end

NS_ASSUME_NONNULL_END

#endif
