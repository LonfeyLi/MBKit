//
//  MBAlertControllerManager.h
//  MBKit_Example
//
//  Created by 李龙飞 on 2021/7/7.
//  Copyright © 2021 LoneyLi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBAlertControllerManager;
NS_ASSUME_NONNULL_BEGIN
typedef void (^MBAlertBuilder)(MBAlertControllerManager *make);

@interface MBAlertControllerManager : NSObject
+ (UIAlertController *)makeAlert:(MBAlertBuilder)block;
+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController;
+ (void)makeAlert:(MBAlertBuilder)block showFrom:(UIViewController *)viewController;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *button;
@end

@interface MBAlertAction : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIAlertAction *action;
@end

NS_ASSUME_NONNULL_END
