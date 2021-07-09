//
//  MBKitManager.h
//  MBKit
//
//  Created by 李龙飞 on 2021/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBKitManager : NSObject

+ (nonnull MBKitManager *)shareInstance;

#pragma mark - Doraemon
/**
 开启哆啦A梦开发工具
 params pid 产品id
 */
- (void)startDoraemonManagerWithPid:(NSString *)pid;

- (void)showDoraemon;

- (void)hiddenDoraemon;

@end

NS_ASSUME_NONNULL_END
