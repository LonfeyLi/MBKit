//
//  MBNetworkAlertController.m
//  MBKit_Example
//
//  Created by 李龙飞 on 2021/7/7.
//  Copyright © 2021 LoneyLi. All rights reserved.
//

#import "MBNetworkAlertController.h"

#define MBAlertActionMutationAssertion() \
NSAssert(!self._action, @"Cannot mutate action after retreiving underlying UIAlertAction");
@interface MBNetworkAlertController ()
@property (nonatomic, readonly) UIAlertController *_controller;
@property (nonatomic, readonly) NSMutableArray<MBNewworkAlertAction *> *_actions;
@end

@implementation MBNetworkAlertController

- (instancetype)initWithController:(UIAlertController *)controller {
    self = [super init];
    if (self) {
        __controller = controller;
        __actions = [NSMutableArray new];
    }

    return self;
}

+ (UIAlertController *)make:(MBAlertBuilder)block withStyle:(UIAlertControllerStyle)style {
    // Create alert builder
    MBNetworkAlertController *alert = [[self alloc] initWithController:
        [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style]
    ];
    block(alert);
    for (MBNewworkAlertAction *builder in alert._actions) {
        [alert._controller addAction:builder.action];
    }
    return alert._controller;
}
+ (UIAlertController *)makeAlert:(MBAlertBuilder)block  {
    return [self make:block withStyle:UIAlertControllerStyleAlert];
}
+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController {
    [self makeAlert:^(MBNetworkAlertController *make) {
        make.title = title;
        make.message = message;
        make.button = @"Dissmiss";
    } showFrom:viewController];
}
+ (void)makeAlert:(MBAlertBuilder)block showFrom:(UIViewController *)viewController {
    [self make:block withStyle:UIAlertControllerStyleAlert showFrom:viewController source:nil];
}
+ (void)make:(MBAlertBuilder)block
   withStyle:(UIAlertControllerStyle)style
    showFrom:(UIViewController *)viewController
      source:(id)viewOrBarItem {
    UIAlertController *alert = [self make:block withStyle:style];
    if ([viewOrBarItem isKindOfClass:[UIBarButtonItem class]]) {
        alert.popoverPresentationController.barButtonItem = viewOrBarItem;
    } else if ([viewOrBarItem isKindOfClass:[UIView class]]) {
        alert.popoverPresentationController.sourceView = viewOrBarItem;
        alert.popoverPresentationController.sourceRect = [viewOrBarItem bounds];
    } else if (viewOrBarItem) {
        NSParameterAssert(
            [viewOrBarItem isKindOfClass:[UIBarButtonItem class]] ||
            [viewOrBarItem isKindOfClass:[UIView class]] ||
            !viewOrBarItem
        );
    }
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end

@implementation MBNewworkAlertAction


@end
