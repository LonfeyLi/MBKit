//
//  MBNetworkTransaction.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkTransaction.h"

@interface MBNetworkTransaction ()
@property (nonatomic, readwrite) NSData *cachedRequestBody;
@end

@implementation MBNetworkTransaction
- (NSString *)description {
    NSString *description = [super description];

    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    description = [description stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];

    return description;
}

- (NSData *)cachedRequestBody {
    if (!_cachedRequestBody) {
        if (self.request.HTTPBody != nil) {
            _cachedRequestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            const NSUInteger bufferSize = 1024;
            uint8_t buffer[bufferSize];
            NSMutableData *data = [NSMutableData new];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:bufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _cachedRequestBody = data;
        }
    }
    return _cachedRequestBody;
}

+ (NSString *)readableStringFromTransactionState:(MBNetworkTransactionState)state {
    NSString *readableString = nil;
    switch (state) {
        case MBNetworkTransactionStateUnstarted:
            readableString = @"Unstarted";
            break;

        case MBNetworkTransactionStateAwaitingResponse:
            readableString = @"Awaiting Response";
            break;

        case MBNetworkTransactionStateReceivingData:
            readableString = @"Receiving Data";
            break;

        case MBNetworkTransactionStateFinished:
            readableString = @"Finished";
            break;

        case MBNetworkTransactionStateFailed:
            readableString = @"Failed";
            break;
    }
    return readableString;
}
@end

