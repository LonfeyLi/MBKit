//
//  MBNetworkDetailTableViewCell.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/22.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBNetworkDetailTableViewCell : UITableViewCell
+ (CGFloat)preferredHeightWithAttributedText:(NSAttributedString *)attributedText
                                    maxWidth:(CGFloat)contentViewWidth
                                       style:(UITableViewStyle)style
                              showsAccessory:(BOOL)showsAccessory;
@end

NS_ASSUME_NONNULL_END

