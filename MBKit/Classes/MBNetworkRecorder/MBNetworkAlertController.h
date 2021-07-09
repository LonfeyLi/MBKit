//
//  MBNetworkAlertController.h
//  MBKit_Example
//
//  Created by 李龙飞 on 2021/7/7.
//  Copyright © 2021 LonfeyLi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBNetworkAlertController;
NS_ASSUME_NONNULL_BEGIN
typedef void (^MBAlertBuilder)(MBNetworkAlertController *make);

@interface MBNetworkAlertController : NSObject
+ (UIAlertController *)makeAlert:(MBAlertBuilder)block;
+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController;
+ (void)makeAlert:(MBAlertBuilder)block showFrom:(UIViewController *)viewController;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *button;
@end

@interface MBNewworkAlertAction : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIAlertAction *action;
@end

NS_ASSUME_NONNULL_END
