//
//  MBNetworkTransactionTableViewCell.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MBNetworkTransaction.h"
NS_ASSUME_NONNULL_BEGIN

@interface MBNetworkTransactionTableViewCell : UITableViewCell
@property (nonatomic) MBNetworkTransaction *transaction;

+ (CGFloat)preferredCellHeight;
@end

NS_ASSUME_NONNULL_END

