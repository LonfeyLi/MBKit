//
//  MBKitManager.m
//  MBKit
//
//  Created by 李龙飞 on 2021/7/9.
//

#import "MBKitManager.h"
#import "DoraemonManager.h"
@implementation MBKitManager
+ (nonnull MBKitManager *)shareInstance{
    static dispatch_once_t once;
    static MBKitManager *instance;
    dispatch_once(&once, ^{
        instance = [[MBKitManager alloc] init];
    });
    return instance;
}

- (void)startDoraemonManagerWithPid:(NSString *)pid {
    [[DoraemonManager shareInstance] addPluginWithTitle:@"抓包工具" icon:@"doraemon_net" desc:@"" pluginName:@"MBDoraemonNetworkPlugin" atModule:@"多鹿工具"];
    [[DoraemonManager shareInstance] installWithPid:pid];
    [[DoraemonManager shareInstance] hiddenDoraemon];
}
- (void)showDoraemon {
    [[DoraemonManager shareInstance] showDoraemon];
}

- (void)hiddenDoraemon {
    [[DoraemonManager shareInstance] hiddenDoraemon];
}

@end
