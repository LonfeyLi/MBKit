//
//  MBNetworkSettingViewController.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/22.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import "MBNetworkSettingViewController.h"
#import "MBNetworkRecorder.h"
#import "MBNetworkObserver.h"
#import "MBNetworkUtility.h"
#import "Masonry.h"
@interface MBNetworkSettingViewController ()<UIActionSheetDelegate>

@property (nonatomic) NSMutableArray<NSString *> *hostBlacklist;

@end

@implementation MBNetworkSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Network Setting";
    UILabel *enableLabel = [UILabel new];
    enableLabel.text = @"Network Debugging";
    enableLabel.font = [UIFont systemFontOfSize:15.f];
    [self.view addSubview:enableLabel];
    [enableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(self.view).offset(40+44+[MBNetworkUtility getStatusBarHight]);
    }];
    UISwitch *enableSwitch = [UISwitch new];
    enableSwitch.on = MBNetworkObserver.enabled;
    [enableSwitch addTarget:self action:@selector(networkDebuggingToggled:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:enableSwitch];
    [enableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(enableLabel);
        make.right.equalTo(self.view).offset(-16);
    }];
    //
    UILabel *cacheMediaLabel = [UILabel new];
    cacheMediaLabel.text = @"Cache Media Responses";
    cacheMediaLabel.font = [UIFont systemFontOfSize:15.f];
    [self.view addSubview:cacheMediaLabel];
    [cacheMediaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(enableLabel.mas_bottom).offset(40);
    }];
    UISwitch *cacheMediaSwitch = [UISwitch new];
    cacheMediaSwitch.on = MBNetworkRecorder.defaultRecorder.shouldCacheMediaResponses;
    [cacheMediaSwitch addTarget:self action:@selector(cacheMediaResponsesToggled:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:cacheMediaSwitch];
    [cacheMediaSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-16);
        make.centerY.equalTo(cacheMediaLabel);
    }];
    //
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"Clear Network History" forState:UIControlStateNormal];
    [clearButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [clearButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [clearButton addTarget:self action:@selector(clearNetworkRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(cacheMediaLabel.mas_bottom).offset(40);
    }];
}


#pragma mark - Settings Actions

- (void)networkDebuggingToggled:(UISwitch *)sender {
    MBNetworkObserver.enabled = sender.isOn;
}

- (void)cacheMediaResponsesToggled:(UISwitch *)sender {
    MBNetworkRecorder.defaultRecorder.shouldCacheMediaResponses = sender.isOn;
}
- (void)clearNetworkRecord {
    [MBNetworkRecorder.defaultRecorder clearRecordedActivity];
}
/*
#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.hostBlacklist.count ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 5;
        case 1: return self.hostBlacklist.count;
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"General";
        case 1: return @"Host Blacklist";
        default: return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"By default, JSON is rendered in a webview. Turn on "
        "\"View JSON as a dictionary/array\" to convert JSON payloads "
        "to objects and view them in an object explorer. "
        "This setting requires a restart of the app.";
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kFLEXDefaultCell forIndexPath:indexPath
    ];
    
    cell.accessoryView = nil;
    cell.textLabel.textColor = FLEXColor.primaryTextColor;
    
    switch (indexPath.section) {
        // Settings
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Network Debugging";
                    cell.accessoryView = self.observerSwitch;
                    break;
                case 1:
                    cell.textLabel.text = @"Cache Media Responses";
                    cell.accessoryView = self.cacheMediaSwitch;
                    break;
                case 2:
                    cell.textLabel.text = @"View JSON as a dictionary/array";
                    cell.accessoryView = self.jsonViewerSwitch;
                    break;
                case 3:
                    cell.textLabel.text = @"Reset Host Blacklist";
                    cell.textLabel.textColor = tableView.tintColor;
                    break;
                case 4:
                    cell.textLabel.text = self.cacheLimitCellTitle;
                    self.cacheLimitLabel = cell.textLabel;
                    [self.cacheLimitSlider removeFromSuperview];
                    [cell.contentView addSubview:self.cacheLimitSlider];
                    
                    CGRect container = cell.contentView.frame;
                    UISlider *slider = self.cacheLimitSlider;
                    [slider sizeToFit];
                    
                    CGFloat sliderWidth = 150.f;
                    CGFloat sliderOriginY = FLEXFloor((container.size.height - slider.frame.size.height) / 2.0);
                    CGFloat sliderOriginX = CGRectGetMaxX(container) - sliderWidth - tableView.separatorInset.left;
                    self.cacheLimitSlider.frame = CGRectMake(
                        sliderOriginX, sliderOriginY, sliderWidth, slider.frame.size.height
                    );
                    
                    // Make wider, keep in middle of cell, keep to trailing edge of cell
                    self.cacheLimitSlider.autoresizingMask = ({
                        UIViewAutoresizingFlexibleWidth |
                        UIViewAutoresizingFlexibleLeftMargin |
                        UIViewAutoresizingFlexibleTopMargin |
                        UIViewAutoresizingFlexibleBottomMargin;
                    });
                    break;
            }
            
            break;
        }
        
        // Blacklist entries
        case 1: {
            cell.textLabel.text = self.hostBlacklist[indexPath.row];
            break;
        }
        
        default:
            @throw NSInternalInconsistencyException;
            break;
    }

    return cell;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)ip {
    // Can only select the "Reset Host Blacklist" row
    return ip.section == 0 && ip.row == 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [FLEXAlert makeAlert:^(FLEXAlert *make) {
        make.title(@"Reset Host Blacklist");
        make.message(@"You cannot undo this action. Are you sure?");
        make.button(@"Reset").destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            self.hostBlacklist = nil;
            [FLEXNetworkRecorder.defaultRecorder.hostBlacklist removeAllObjects];
            [FLEXNetworkRecorder.defaultRecorder synchronizeBlacklist];
            [self.tableView deleteSections:
                [NSIndexSet indexSetWithIndex:1]
            withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)style
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(style == UITableViewCellEditingStyleDelete);
    
    NSString *host = self.hostBlacklist[indexPath.row];
    [self.hostBlacklist removeObjectAtIndex:indexPath.row];
    [FLEXNetworkRecorder.defaultRecorder.hostBlacklist removeObject:host];
    [FLEXNetworkRecorder.defaultRecorder synchronizeBlacklist];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#endif
