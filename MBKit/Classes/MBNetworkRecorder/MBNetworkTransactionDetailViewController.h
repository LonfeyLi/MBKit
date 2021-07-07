//
//  MBNetworkTransactionDetailViewController.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import <UIKit/UIKit.h>
#import "DoraemonBaseViewController.h"
#import "MBNetworkTransaction.h"
NS_ASSUME_NONNULL_BEGIN

@interface MBNetworkTransactionDetailViewController : DoraemonBaseViewController
@property (nonatomic, strong) MBNetworkTransaction *transaction;
@end



NS_ASSUME_NONNULL_END

#endif
