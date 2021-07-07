//
//  MBDoraemonNetworkPlugin.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import "MBDoraemonNetworkPlugin.h"
#import "MBNetworkMITMViewController.h"
#import "DoraemonManager.h"
#import "DoraemonHomeWindow.h"
@implementation MBDoraemonNetworkPlugin
- (void)pluginDidLoad{
    MBNetworkMITMViewController *vc = [[MBNetworkMITMViewController alloc] init];
    [DoraemonHomeWindow openPlugin:vc];
}
@end

#endif
