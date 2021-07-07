//
//  MBNetworkObserver.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString *const kMBNetworkObserverEnabledStateChangedNotification;

@interface MBNetworkObserver : NSObject
@property (nonatomic, class, getter=isEnabled) BOOL enabled;
@end

NS_ASSUME_NONNULL_END

#endif
