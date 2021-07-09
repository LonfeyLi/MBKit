//
//  MBNetworkTransactionDetailViewController.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkTransactionDetailViewController.h"
#import "MBNetworkWebViewController.h"
#import "DoraemonNavBarItemModel.h"
#import "MBNetworkUtility.h"
#import "MBNetworkRecorder.h"
#import "MBNetworkResources.h"
#import "MBNetworkDetailTableViewCell.h"
#import "MBNetworkWebViewController.h"
#import "MBNetworkAlertController.h"
#import "masonry.h"
typedef UIViewController * _Nullable(^MBCustomContentViewerFuture)(NSData *data);
@interface MBNetworkTransactionDetailViewController ()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray<MBNetworkDetailSection *> *sections;
@end

@implementation MBNetworkTransactionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DoraemonNavBarItemModel *copyModel = [[DoraemonNavBarItemModel alloc] initWithText:@"Copy curl" color:[UIColor blackColor] selector:@selector(copyButtonPressed)];
    [self setRightNavBarItems:@[copyModel]];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
   
}

- (void)copyButtonPressed {
    [UIPasteboard.generalPasteboard setString:[MBNetworkUtility curlCommandString:self.transaction.request]];
}
- (void)setTransaction:(MBNetworkTransaction *)transaction {
    if (![_transaction isEqual:transaction]) {
        _transaction = transaction;
        self.navigationItem.title = [transaction.request.URL lastPathComponent];
        [self rebuildTableSections];
    }
}

- (void)setSections:(NSArray<MBNetworkDetailSection *> *)sections {
    if (![_sections isEqual:sections]) {
        _sections = [sections copy];
        [self.tableView reloadData];
    }
}

- (void)rebuildTableSections {
    NSMutableArray<MBNetworkDetailSection *> *sections = [NSMutableArray new];

    MBNetworkDetailSection *generalSection = [self generalSectionForTransaction:self.transaction];
    if (generalSection.rows.count > 0) {
        [sections addObject:generalSection];
    }
    MBNetworkDetailSection *requestHeadersSection = [self requestHeadersSectionForTransaction:self.transaction];
    if (requestHeadersSection.rows.count > 0) {
        [sections addObject:requestHeadersSection];
    }
    MBNetworkDetailSection *queryParametersSection = [self queryParametersSectionForTransaction:self.transaction];
    if (queryParametersSection.rows.count > 0) {
        [sections addObject:queryParametersSection];
    }
    MBNetworkDetailSection *postBodySection = [self postBodySectionForTransaction:self.transaction];
    if (postBodySection.rows.count > 0) {
        [sections addObject:postBodySection];
    }
    MBNetworkDetailSection *responseHeadersSection = [self responseHeadersSectionForTransaction:self.transaction];
    if (responseHeadersSection.rows.count > 0) {
        [sections addObject:responseHeadersSection];
    }

    self.sections = sections;
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MBNetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MBNetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBNetworkDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];

    MBNetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];
    cell.textLabel.attributedText = [self attributedTextForRow:rowModel];
    cell.accessoryType = rowModel.selectionFuture ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = rowModel.selectionFuture ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBNetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];

    UIViewController *viewController = nil;
    if (rowModel.selectionFuture) {
        viewController = rowModel.selectionFuture();
    }

    if ([viewController isKindOfClass:UIAlertController.class]) {
        [self presentViewController:viewController animated:YES completion:nil];
    } else if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MBNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
    NSAttributedString *attributedText = [self attributedTextForRow:row];
    BOOL showsAccessory = row.selectionFuture != nil;
    return [MBNetworkDetailTableViewCell preferredHeightWithAttributedText:attributedText
                                                                  maxWidth:tableView.bounds.size.width
                                                                     style:tableView.style
                                                            showsAccessory:showsAccessory];
}

- (MBNetworkDetailRow *)rowModelAtIndexPath:(NSIndexPath *)indexPath {
    MBNetworkDetailSection *sectionModel = self.sections[indexPath.section];
    return sectionModel.rows[indexPath.row];
}

#pragma mark - Cell Copying

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        MBNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
        UIPasteboard.generalPasteboard.string = row.detailText;
    }
}

#if FLEX_AT_LEAST_IOS13_SDK

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction actionWithTitle:@"Copy" image:nil identifier:nil handler:^(__kindof UIAction *action) {
                    MBNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
                    UIPasteboard.generalPasteboard.string = row.detailText;
                }
            ];
            return [UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[copy]
            ];
        }
    ];
}
#endif
#pragma mark -
- (NSAttributedString *)attributedTextForRow:(MBNetworkDetailRow *)row {
    NSDictionary<NSString *, id> *titleAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0],
                                                       NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1.0] };
    NSDictionary<NSString *, id> *detailAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                        NSForegroundColorAttributeName : UIColor.blackColor };

    NSString *title = [NSString stringWithFormat:@"%@: ", row.title];
    NSString *detailText = row.detailText ?: @"";
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:titleAttributes]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:detailText attributes:detailAttributes]];

    return attributedText;
}
#pragma mark -
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 56;
        [_tableView registerClass:[MBNetworkDetailTableViewCell class] forCellReuseIdentifier:@"cellId"];
    }
    return _tableView;
}
#pragma mark - Table Data Generation

- (MBNetworkDetailSection *)generalSectionForTransaction:(MBNetworkTransaction *)transaction {
    NSMutableArray<MBNetworkDetailRow *> *rows = [NSMutableArray new];

    MBNetworkDetailRow *requestURLRow = [MBNetworkDetailRow new];
    requestURLRow.title = @"Request URL";
    NSURL *url = transaction.request.URL;
    requestURLRow.detailText = url.absoluteString;
    requestURLRow.selectionFuture = ^{
        MBNetworkWebViewController *wkwebVC = [[MBNetworkWebViewController alloc] initWithURL:url];
        wkwebVC.title = url.absoluteString;
        return wkwebVC;
    };
    [rows addObject:requestURLRow];

    MBNetworkDetailRow *requestMethodRow = [MBNetworkDetailRow new];
    requestMethodRow.title = @"Request Method";
    requestMethodRow.detailText = transaction.request.HTTPMethod;
    [rows addObject:requestMethodRow];

    if (transaction.cachedRequestBody.length > 0) {
        MBNetworkDetailRow *postBodySizeRow = [MBNetworkDetailRow new];
        postBodySizeRow.title = @"Request Body Size";
        postBodySizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.cachedRequestBody.length countStyle:NSByteCountFormatterCountStyleBinary];
        [rows addObject:postBodySizeRow];

        MBNetworkDetailRow *postBodyRow = [MBNetworkDetailRow new];
        postBodyRow.title = @"Request Body";
        postBodyRow.detailText = @"tap to view";
        postBodyRow.selectionFuture = ^UIViewController * () {
            // Show the body if we can
            NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
            UIViewController *detailViewController = [self detailViewControllerForMIMEType:contentType data:[self postBodyDataForTransaction:transaction]];
            if (detailViewController) {
                detailViewController.title = @"Request Body";
                return detailViewController;
            }

            // We can't show the body, alert user
            
            return [MBNetworkAlertController makeAlert:^(MBNetworkAlertController * _Nonnull make) {
                make.title = @"Can't View HTTP Body Data";
                make.message = (@"FLEX does not have a viewer for request body data with MIME type: ");
                make.button = @"Dismiss";
            }];
        };

        [rows addObject:postBodyRow];
    }

    NSString *statusCodeString = [MBNetworkUtility statusCodeStringFromURLResponse:transaction.response];
    if (statusCodeString.length > 0) {
        MBNetworkDetailRow *statusCodeRow = [MBNetworkDetailRow new];
        statusCodeRow.title = @"Status Code";
        statusCodeRow.detailText = statusCodeString;
        [rows addObject:statusCodeRow];
    }

    if (transaction.error) {
        MBNetworkDetailRow *errorRow = [MBNetworkDetailRow new];
        errorRow.title = @"Error";
        errorRow.detailText = transaction.error.localizedDescription;
        [rows addObject:errorRow];
    }

    MBNetworkDetailRow *responseBodyRow = [MBNetworkDetailRow new];
    responseBodyRow.title = @"Response Body";
    NSData *responseData = [MBNetworkRecorder.defaultRecorder cachedResponseBodyForTransaction:transaction];
    if (responseData.length > 0) {
        responseBodyRow.detailText = @"tap to view";

        // Avoid a long lived strong reference to the response data in case we need to purge it from the cache.
        __weak NSData *weakResponseData = responseData;
        responseBodyRow.selectionFuture = ^UIViewController * () {
            // Show the response if we can
            NSString *contentType = transaction.response.MIMEType;
            NSData *strongResponseData = weakResponseData;
            if (strongResponseData) {
                UIViewController *bodyDetailController = [self detailViewControllerForMIMEType:contentType data:strongResponseData];
                if (bodyDetailController) {
                    bodyDetailController.title = @"Response";
                    return bodyDetailController;
                }
            }
            return [MBNetworkAlertController makeAlert:^(MBNetworkAlertController * _Nonnull make) {
                make.title = @"Unable to View Response";
                if (strongResponseData) {
                    make.message = @"No viewer content type: ";
                } else {
                    make.message = @"The response has been purged from the cache";
                }
                make.button = @"OK";
            }];
        };
    } else {
        BOOL emptyResponse = transaction.receivedDataLength == 0;
        responseBodyRow.detailText = emptyResponse ? @"empty" : @"not in cache";
    }
    [rows addObject:responseBodyRow];

    MBNetworkDetailRow *responseSizeRow = [MBNetworkDetailRow new];
    responseSizeRow.title = @"Response Size";
    responseSizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary];
    [rows addObject:responseSizeRow];

    MBNetworkDetailRow *mimeTypeRow = [MBNetworkDetailRow new];
    mimeTypeRow.title = @"MIME Type";
    mimeTypeRow.detailText = transaction.response.MIMEType;
    [rows addObject:mimeTypeRow];

    MBNetworkDetailRow *mechanismRow = [MBNetworkDetailRow new];
    mechanismRow.title = @"Mechanism";
    mechanismRow.detailText = transaction.requestMechanism;
    [rows addObject:mechanismRow];

    NSDateFormatter *startTimeFormatter = [NSDateFormatter new];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

    MBNetworkDetailRow *localStartTimeRow = [MBNetworkDetailRow new];
    localStartTimeRow.title = [NSString stringWithFormat:@"Start Time (%@)", [NSTimeZone.localTimeZone abbreviationForDate:transaction.startTime]];
    localStartTimeRow.detailText = [startTimeFormatter stringFromDate:transaction.startTime];
    [rows addObject:localStartTimeRow];

    startTimeFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    MBNetworkDetailRow *utcStartTimeRow = [MBNetworkDetailRow new];
    utcStartTimeRow.title = @"Start Time (UTC)";
    utcStartTimeRow.detailText = [startTimeFormatter stringFromDate:transaction.startTime];
    [rows addObject:utcStartTimeRow];

    MBNetworkDetailRow *unixStartTime = [MBNetworkDetailRow new];
    unixStartTime.title = @"Unix Start Time";
    unixStartTime.detailText = [NSString stringWithFormat:@"%f", [transaction.startTime timeIntervalSince1970]];
    [rows addObject:unixStartTime];

    MBNetworkDetailRow *durationRow = [MBNetworkDetailRow new];
    durationRow.title = @"Total Duration";
    durationRow.detailText = [MBNetworkUtility stringFromRequestDuration:transaction.duration];
    [rows addObject:durationRow];

    MBNetworkDetailRow *latencyRow = [MBNetworkDetailRow new];
    latencyRow.title = @"Latency";
    latencyRow.detailText = [MBNetworkUtility stringFromRequestDuration:transaction.latency];
    [rows addObject:latencyRow];

    MBNetworkDetailSection *generalSection = [MBNetworkDetailSection new];
    generalSection.title = @"General";
    generalSection.rows = rows;

    return generalSection;
}

- (MBNetworkDetailSection *)requestHeadersSectionForTransaction:(MBNetworkTransaction *)transaction {
    MBNetworkDetailSection *requestHeadersSection = [MBNetworkDetailSection new];
    requestHeadersSection.title = @"Request Headers";
    requestHeadersSection.rows = [self networkDetailRowsFromDictionary:transaction.request.allHTTPHeaderFields];

    return requestHeadersSection;
}

- (MBNetworkDetailSection *)postBodySectionForTransaction:(MBNetworkTransaction *)transaction {
    MBNetworkDetailSection *postBodySection = [MBNetworkDetailSection new];
    postBodySection.title = @"Request Body Parameters";
    if (transaction.cachedRequestBody.length > 0) {
        NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSData *body = [self postBodyDataForTransaction:transaction];
            NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
            postBodySection.rows = [self networkDetailRowsFromQueryItems:[MBNetworkUtility itemsFromQueryString:bodyString]];
        }
    }
    return postBodySection;
}

- (MBNetworkDetailSection *)queryParametersSectionForTransaction:(MBNetworkTransaction *)transaction {
    NSArray<NSURLQueryItem *> *queries = [MBNetworkUtility itemsFromQueryString:transaction.request.URL.query];
    MBNetworkDetailSection *querySection = [MBNetworkDetailSection new];
    querySection.title = @"Query Parameters";
    querySection.rows = [self networkDetailRowsFromQueryItems:queries];

    return querySection;
}

- (MBNetworkDetailSection *)responseHeadersSectionForTransaction:(MBNetworkTransaction *)transaction {
    MBNetworkDetailSection *responseHeadersSection = [MBNetworkDetailSection new];
    responseHeadersSection.title = @"Response Headers";
    if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)transaction.response;
        responseHeadersSection.rows = [self networkDetailRowsFromDictionary:httpResponse.allHeaderFields];
    }
    return responseHeadersSection;
}

- (NSArray<MBNetworkDetailRow *> *)networkDetailRowsFromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    NSMutableArray<MBNetworkDetailRow *> *rows = [NSMutableArray new];
    NSArray<NSString *> *sortedKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        id value = dictionary[key];
        MBNetworkDetailRow *row = [MBNetworkDetailRow new];
        row.title = key;
        row.detailText = [value description];
        [rows addObject:row];
    }

    return rows.copy;
}

- (NSArray<MBNetworkDetailRow *> *)networkDetailRowsFromQueryItems:(NSArray<NSURLQueryItem *> *)items {
    // Sort the items by name
    items = [items sortedArrayUsingComparator:^NSComparisonResult(NSURLQueryItem *item1, NSURLQueryItem *item2) {
        return [item1.name caseInsensitiveCompare:item2.name];
    }];

    NSMutableArray<MBNetworkDetailRow *> *rows = [NSMutableArray new];
    for (NSURLQueryItem *item in items) {
        MBNetworkDetailRow *row = [MBNetworkDetailRow new];
        row.title = item.name;
        row.detailText = item.value;
        [rows addObject:row];
    }

    return [rows copy];
}

- (UIViewController *)detailViewControllerForMIMEType:(NSString *)mimeType data:(NSData *)data {

    // FIXME (RKO): Don't rely on UTF8 string encoding
    UIViewController *detailViewController = nil;
    if ([MBNetworkUtility isValidJSONData:data]) {
        NSString *jsonString = [MBNetworkUtility prettyJSONStringFromData:data];
        if (jsonString.length>0) {
            detailViewController = [[MBNetworkWebViewController alloc] initWithText:jsonString];
        }
    } else if ([mimeType hasPrefix:@"image/"]) {
        UIImage *image = [UIImage imageWithData:data];
        detailViewController = [[MBNetworkWebViewController alloc] initWithImage:image];
    } else if ([mimeType isEqual:@"application/x-plist"]) {
        id propertyList = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
        detailViewController = [[MBNetworkWebViewController alloc] initWithText:[propertyList description]];
    }

    // Fall back to trying to show the response as text
    if (!detailViewController) {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (text.length > 0) {
            detailViewController = [[MBNetworkWebViewController alloc] initWithText:text];
        }
    }
    return detailViewController;
}

- (NSData *)postBodyDataForTransaction:(MBNetworkTransaction *)transaction {
    NSData *bodyData = transaction.cachedRequestBody;
    if (bodyData.length > 0) {
        NSString *contentEncoding = [transaction.request valueForHTTPHeaderField:@"Content-Encoding"];
        if ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0) {
            bodyData = [MBNetworkUtility inflatedDataFromCompressedData:bodyData];
        }
    }
    return bodyData;
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


