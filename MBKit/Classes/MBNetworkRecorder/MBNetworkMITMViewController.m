//
//  MBNetworkMITMViewController.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkMITMViewController.h"
#import "MBNetworkTransactionDetailViewController.h"
#import "MBNetworkTransactionTableViewCell.h"
#import "MBNetworkRecorder.h"
#import "MBNetworkObserver.h"
#import "DoraemonHomeWindow.h"
#import "DoraemonNavBarItemModel.h"
#import "MBNetworkSettingViewController.h"
#import "Masonry.h"
@interface MBNetworkMITMViewController ()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray<MBNetworkTransaction *> *networkTransactions;
@property (nonatomic) long long bytesReceived;
@property (nonatomic) BOOL pendingReload;
@property (nonatomic) BOOL rowInsertInProgress;
@end

@implementation MBNetworkMITMViewController

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Network History";
    DoraemonNavBarItemModel *settingModel = [[DoraemonNavBarItemModel alloc] initWithText:@"设置" color:[UIColor blackColor] selector:@selector(networkHistorySetting)];
    [self setRightNavBarItems:@[settingModel]];
    //
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self registerForNotifications];
    [self updateTransactions];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Reload the table if we received updates while not on-screen
    if (self.pendingReload) {
        [self.tableView reloadData];
        self.pendingReload = NO;
    }
}

#pragma mark - Notification
- (void)registerForNotifications {
    NSDictionary *notifications = @{
        kMBNetworkRecorderNewTransactionNotification:
            NSStringFromSelector(@selector(handleNewTransactionRecordedNotification:)),
        kMBNetworkRecorderTransactionUpdatedNotification:
            NSStringFromSelector(@selector(handleTransactionUpdatedNotification:)),
        kMBNetworkRecorderTransactionsClearedNotification:
            NSStringFromSelector(@selector(handleTransactionsClearedNotification:)),
        kMBNetworkObserverEnabledStateChangedNotification:
            NSStringFromSelector(@selector(handleNetworkObserverEnabledStateChangedNotification:)),
    };
    
    for (NSString *name in notifications.allKeys) {
        [NSNotificationCenter.defaultCenter addObserver:self
            selector:NSSelectorFromString(notifications[name]) name:name object:nil
        ];
    }
}

- (void)handleNewTransactionRecordedNotification:(NSNotification *)notification {
    [self tryUpdateTransactions];
}
- (void)handleTransactionUpdatedNotification:(NSNotification *)notification {
    [self updateBytesReceived];

    MBNetworkTransaction *transaction = notification.userInfo[kMBNetworkRecorderUserInfoTransactionKey];

    // Update both the main table view and search table view if needed.
    for (MBNetworkTransactionTableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell.transaction isEqual:transaction]) {
            // Using -[UITableView reloadRowsAtIndexPaths:withRowAnimation:] is overkill here and kicks off a lot of
            // work that can make the table view somewhat unresponsive when lots of updates are streaming in.
            // We just need to tell the cell that it needs to re-layout.
            [cell setNeedsLayout];
            break;
        }
    }
    [self updateFirstSectionHeader];
}

- (void)handleTransactionsClearedNotification:(NSNotification *)notification {
    self.bytesReceived = 0;
    [self updateTransactions];
    [self.tableView reloadData];
}

- (void)handleNetworkObserverEnabledStateChangedNotification:(NSNotification *)notification {
    // Update the header, which displays a warning when network debugging is disabled
    [self updateFirstSectionHeader];
}

#pragma mark - private

- (void)networkHistorySetting {
    MBNetworkSettingViewController *settingVC = [MBNetworkSettingViewController new];
    [self.navigationController pushViewController:settingVC animated:YES];
}
- (void)updateTransactions {
    self.networkTransactions = [MBNetworkRecorder.defaultRecorder networkTransactions];
}
- (void)updateBytesReceived {
    long long bytesReceived = 0;
    for (MBNetworkTransaction *transaction in self.networkTransactions) {
        bytesReceived += transaction.receivedDataLength;
    }
    self.bytesReceived = bytesReceived;
    [self updateFirstSectionHeader];
}

- (void)tryUpdateTransactions {
    // Don't do any view updating if we aren't in the view hierarchy
    if (!self.viewIfLoaded.window) {
        [self updateTransactions];
        self.pendingReload = YES;
        return;
    }
    
    // Let the previous row insert animation finish before starting a new one to avoid stomping.
    // We'll try calling the method again when the insertion completes,
    // and we properly no-op if there haven't been changes.
    if (self.rowInsertInProgress) {
        return;
    }
       

    NSInteger existingRowCount = self.networkTransactions.count;
    [self updateTransactions];
    NSInteger newRowCount = self.networkTransactions.count;
    NSInteger addedRowCount = newRowCount - existingRowCount;

    if (addedRowCount != 0) {
        // Insert animation if we're at the top.
        if (self.tableView.contentOffset.y <= 0.0 && addedRowCount > 0) {
            [CATransaction begin];
            
            self.rowInsertInProgress = YES;
            [CATransaction setCompletionBlock:^{
                self.rowInsertInProgress = NO;
                [self tryUpdateTransactions];
            }];

            NSMutableArray<NSIndexPath *> *indexPathsToReload = [NSMutableArray new];
            for (NSInteger row = 0; row < addedRowCount; row++) {
                [indexPathsToReload addObject:[NSIndexPath indexPathForRow:row inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];

            [CATransaction commit];
        } else {
            // Maintain the user's position if they've scrolled down.
            CGSize existingContentSize = self.tableView.contentSize;
            [self.tableView reloadData];
            CGFloat contentHeightChange = self.tableView.contentSize.height - existingContentSize.height;
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + contentHeightChange);
        }
    }
}
- (void)updateFirstSectionHeader {
    UIView *view = [self.tableView headerViewForSection:0];
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self headerText];
        [headerView setNeedsLayout];
    }
}
- (NSString *)headerText {
    long long bytesReceived = 0;
    NSInteger totalRequests = 0;
    bytesReceived = self.bytesReceived;
    totalRequests = self.networkTransactions.count;
    
    NSString *byteCountText = [NSByteCountFormatter
        stringFromByteCount:bytesReceived countStyle:NSByteCountFormatterCountStyleBinary
    ];
    NSString *requestsText = totalRequests == 1 ? @"Request" : @"Requests";
    return [NSString stringWithFormat:@"%@ %@ (%@ received)",
        @(totalRequests), requestsText, byteCountText
    ];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.networkTransactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self headerText];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBNetworkTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.transaction = self.networkTransactions[indexPath.row];
    NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];
    if ((totalRows - indexPath.row) % 2 == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = UIColor.whiteColor;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MBNetworkTransactionDetailViewController *detailViewController = [MBNetworkTransactionDetailViewController new];
    detailViewController.transaction = self.networkTransactions[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark -
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 56;
        [_tableView registerClass:[MBNetworkTransactionTableViewCell class] forCellReuseIdentifier:@"cellId"];
    }
    return _tableView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

