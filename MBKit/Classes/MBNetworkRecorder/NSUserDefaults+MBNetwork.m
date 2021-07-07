//
//  NSUserDefaults+MBNetwork.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import "NSUserDefaults+MBNetwork.h"

NSString * const kMBDefaultsNetworkHostBlacklistKey = @"com.flipboard.MB.network_host_blacklist";

@implementation NSUserDefaults (MBNetwork)
- (NSArray<NSString *> *)mb_networkHostBlacklist {
    return [NSArray arrayWithContentsOfFile:[
        self mb_defaultsPathForFile:kMBDefaultsNetworkHostBlacklistKey
    ]] ?: @[];
}

- (void)setMb_networkHostBlacklist:(NSArray<NSString *> *)blacklist {
    NSParameterAssert(blacklist);
    [blacklist writeToFile:[
        self mb_defaultsPathForFile:kMBDefaultsNetworkHostBlacklistKey
    ] atomically:YES];
}
- (NSString *)mb_defaultsPathForFile:(NSString *)filename {
    filename = [filename stringByAppendingPathExtension:@"plist"];
    
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(
        NSLibraryDirectory, NSUserDomainMask, YES
    );
    NSString *preferences = [paths[0] stringByAppendingPathComponent:@"Preferences"];
    return [preferences stringByAppendingPathComponent:filename];
}

@end

#endif
