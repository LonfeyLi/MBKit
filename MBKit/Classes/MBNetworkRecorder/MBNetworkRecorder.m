//
//  MBNetworkRecorder.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import "MBNetworkRecorder.h"
#import "NSUserDefaults+MBNetwork.h"
#import "NSArray+MBNetwork.h"
#import "MBNetworkResources.h"
NSString *const kMBNetworkRecorderTransactionsClearedNotification = @"kMBNetworkRecorderTransactionsClearedNotification";
NSString *const kMBNetworkRecorderTransactionUpdatedNotification = @"kMBNetworkRecorderTransactionUpdatedNotification";
NSString *const kMBNetworkRecorderNewTransactionNotification = @"kMBNetworkRecorderNewTransactionNotification";
NSString *const kMBNetworkRecorderUserInfoTransactionKey = @"transaction";
@interface MBNetworkRecorder ()

@property (nonatomic) NSCache *responseCache;
@property (nonatomic) NSMutableArray<MBNetworkTransaction *> *orderedTransactions;
@property (nonatomic) NSMutableDictionary<NSString *, MBNetworkTransaction *> *requestIDsToTransactions;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation MBNetworkRecorder
- (instancetype)init {
    self = [super init];
    if (self) {
        self.responseCache = [NSCache new];
        
        // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
        self.responseCache.totalCostLimit = 25 * 1024 * 1024;
        [self.responseCache setTotalCostLimit:25 * 1024 * 1024];
        
        self.orderedTransactions = [NSMutableArray new];
        self.requestIDsToTransactions = [NSMutableDictionary new];
        self.hostBlacklist = NSUserDefaults.standardUserDefaults.mb_networkHostBlacklist.mutableCopy;

        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.flex.FLEXNetworkRecorder", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)defaultRecorder {
    static MBNetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [self new];
    });
    
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit {
    return self.responseCache.totalCostLimit;
}

- (NSArray<MBNetworkTransaction *> *)networkTransactions {
    __block NSArray<MBNetworkTransaction *> *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = self.orderedTransactions.copy;
    });
    return transactions;
}

- (NSData *)cachedResponseBodyForTransaction:(MBNetworkTransaction *)transaction {
    return [self.responseCache objectForKey:transaction.requestID];
}

- (void)clearRecordedActivity {
    dispatch_async(self.queue, ^{
        [self.responseCache removeAllObjects];
        [self.orderedTransactions removeAllObjects];
        [self.requestIDsToTransactions removeAllObjects];
        
        [self notify:kMBNetworkRecorderTransactionsClearedNotification transaction:nil];
    });
}

- (void)clearBlacklistedTransactions {
    dispatch_sync(self.queue, ^{
        self.orderedTransactions = ({
            [self.orderedTransactions mb_filtered:^BOOL(MBNetworkTransaction *ta, NSUInteger idx) {
                NSString *host = ta.request.URL.host;
                for (NSString *blacklisted in self.hostBlacklist) {
                    if ([host hasSuffix:blacklisted]) {
                        return NO;
                    }
                }
                
                return YES;
            }];
        });
    });
}

- (void)synchronizeBlacklist {
    NSUserDefaults.standardUserDefaults.mb_networkHostBlacklist = self.hostBlacklist;
}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(NSURLRequest *)request
                            redirectResponse:(NSURLResponse *)redirectResponse {
    for (NSString *host in self.hostBlacklist) {
        if ([request.URL.host hasSuffix:host]) {
            return;
        }
    }
    
    // Before async block to stay accurate
    NSDate *startDate = [NSDate date];

    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:[NSData data]];
    }

    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = [MBNetworkTransaction new];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;

        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.requestIDsToTransactions setObject:transaction forKey:requestID];
        transaction.transactionState = MBNetworkTransactionStateAwaitingResponse;

        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response {
    // Before async block to stay accurate
    NSDate *responseDate = [NSDate date];

    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.response = response;
        transaction.transactionState = MBNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength {
    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.receivedDataLength += dataLength;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData * )responseBody {
    NSDate *finishedDate = [NSDate date];

    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.transactionState = MBNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];

        BOOL shouldCache = responseBody.length > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray<NSString *> *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.responseCache setObject:responseBody forKey:requestID cost:responseBody.length];
        }

        NSString *mimeType = transaction.response.MIMEType;
        if ([mimeType hasPrefix:@"image/"] && responseBody.length > 0) {
            // Thumbnail image previews on a separate background queue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSInteger maxPixelDimension = UIScreen.mainScreen.scale * 32.0;
                transaction.responseThumbnail = [self
                    thumbnailedImageWithMaxPixelDimension:maxPixelDimension
                    fromImageData:responseBody
                ];
                [self postUpdateNotificationForTransaction:transaction];
            });
        } else if ([mimeType isEqual:@"application/json"]) {
            transaction.responseThumbnail = MBNetworkResources.jsonIcon;
        } else if ([mimeType isEqual:@"text/plain"]){
            transaction.responseThumbnail = MBNetworkResources.textPlainIcon;
        } else if ([mimeType isEqual:@"text/html"]) {
            transaction.responseThumbnail = MBNetworkResources.htmlIcon;
        } else if ([mimeType isEqual:@"application/x-plist"]) {
            transaction.responseThumbnail = MBNetworkResources.plistIcon;
        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
            transaction.responseThumbnail = MBNetworkResources.binaryIcon;
        } else if ([mimeType containsString:@"javascript"]) {
            transaction.responseThumbnail = MBNetworkResources.jsIcon;
        } else if ([mimeType containsString:@"xml"]) {
            transaction.responseThumbnail = MBNetworkResources.xmlIcon;
        } else if ([mimeType hasPrefix:@"audio"]) {
            transaction.responseThumbnail = MBNetworkResources.audioIcon;
        } else if ([mimeType hasPrefix:@"video"]) {
            transaction.responseThumbnail = MBNetworkResources.videoIcon;
        } else if ([mimeType hasPrefix:@"text"]) {
            transaction.responseThumbnail = MBNetworkResources.textIcon;
        }
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error {
    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.transactionState = MBNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID {
    dispatch_async(self.queue, ^{
        MBNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.requestMechanism = mechanism;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(MBNetworkTransaction *)transaction {
    [self notify:kMBNetworkRecorderNewTransactionNotification transaction:transaction];
}

- (void)postUpdateNotificationForTransaction:(MBNetworkTransaction *)transaction {
    [self notify:kMBNetworkRecorderTransactionUpdatedNotification transaction:transaction];
}

- (void)notify:(NSString *)name transaction:(MBNetworkTransaction *)transaction {
    NSDictionary *userInfo = nil;
    if (transaction) {
        userInfo = @{ kMBNetworkRecorderUserInfoTransactionKey : transaction };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:name object:self userInfo:userInfo];
    });
}
- (UIImage *)thumbnailedImageWithMaxPixelDimension:(NSInteger)dimension fromImageData:(NSData *)data {
    UIImage *thumbnail = nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, 0);
    if (imageSource) {
        NSDictionary<NSString *, id> *options = @{
            (__bridge id)kCGImageSourceCreateThumbnailWithTransform : @YES,
            (__bridge id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
            (__bridge id)kCGImageSourceThumbnailMaxPixelSize : @(dimension)
        };

        CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, (__bridge CFDictionaryRef)options
        );
        if (scaledImageRef) {
            thumbnail = [UIImage imageWithCGImage:scaledImageRef];
            CFRelease(scaledImageRef);
        }
        CFRelease(imageSource);
    }
    return thumbnail;
}
@end

#endif
