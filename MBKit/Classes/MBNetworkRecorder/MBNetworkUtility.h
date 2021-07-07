//
//  MBNetworkUtility.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef RELEASE

NS_ASSUME_NONNULL_BEGIN

@interface MBNetworkUtility : NSObject
+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector
                                     onClass:(Class)cls
                                   withBlock:(id)block
                          swizzledSelector:(SEL)swizzledSelector;

+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls;

+ (void)replaceImplementationOfSelector:(SEL)selector
                           withSelector:(SEL)swizzledSelector
                               forClass:(Class)cls
                  withMethodDescription:(struct objc_method_description)methodDescription
                    implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock;
+ (BOOL)isErrorStatusCodeFromURLResponse:(NSURLResponse *)response;
+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response;
+ (NSString *)curlCommandString:(NSURLRequest *)request;
+ (NSArray<NSURLQueryItem *> *)itemsFromQueryString:(NSString *)query;
+ (NSString *)stringByEscapingHTMLEntitiesInString:(NSString *)originalString;
+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration;
+ (NSString *)prettyJSONStringFromData:(NSData *)data;
+ (BOOL)isValidJSONData:(NSData *)data;
+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData;
/** 分钟数转成分秒 */
+ (NSString *)gold_timeExchange:(CGFloat)time;
/**获取状态栏高度*/
+ (CGFloat)getStatusBarHight;
@end

NS_ASSUME_NONNULL_END

#endif
