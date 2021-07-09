//
//  MBNetworkWebViewController.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/22.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "DoraemonBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBNetworkWebViewController : DoraemonBaseViewController
- (id)initWithURL:(NSURL *)url;
- (id)initWithText:(NSString *)text;
- (id)initWithImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END

