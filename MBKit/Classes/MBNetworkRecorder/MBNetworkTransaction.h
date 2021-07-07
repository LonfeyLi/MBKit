//
//  MBNetworkTransaction.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, MBNetworkTransactionState) {
    MBNetworkTransactionStateUnstarted,
    MBNetworkTransactionStateAwaitingResponse,
    MBNetworkTransactionStateReceivingData,
    MBNetworkTransactionStateFinished,
    MBNetworkTransactionStateFailed
};


@interface MBNetworkTransaction : NSObject
@property (nonatomic, copy) NSString *requestID;

@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic, copy) NSString *requestMechanism;
@property (nonatomic) MBNetworkTransactionState transactionState;
@property (nonatomic) NSError *error;

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval latency;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) int64_t receivedDataLength;

/// Only applicable for image downloads. A small thumbnail to preview the full response.
@property (nonatomic) UIImage *responseThumbnail;

/// Populated lazily. Handles both normal HTTPBody data and HTTPBodyStreams.
@property (nonatomic, readonly) NSData *cachedRequestBody;

+ (NSString *)readableStringFromTransactionState:(MBNetworkTransactionState)state;
@end

NS_ASSUME_NONNULL_END

#endif
