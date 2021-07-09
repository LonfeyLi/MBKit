//
//  MBNetworkUtility.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkUtility.h"
#import <objc/runtime.h>
#import <zlib.h>
@implementation MBNetworkUtility

+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector
                                     onClass:(Class)cls
                                   withBlock:(id)block
                            swizzledSelector:(SEL)swizzledSelector {
    // This method is only intended for swizzling methods that are know to exist on the class.
    // Bail if that isn't the case.
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    if (!originalMethod) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    class_addMethod(cls, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
    method_exchangeImplementations(originalMethod, newMethod);
}
+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls {
    if ([cls instancesRespondToSelector:selector]) {
        unsigned int numMethods = 0;
        Method *methods = class_copyMethodList(cls, &numMethods);
        
        BOOL implementsSelector = NO;
        for (int index = 0; index < numMethods; index++) {
            SEL methodSelector = method_getName(methods[index]);
            if (selector == methodSelector) {
                implementsSelector = YES;
                break;
            }
        }
        
        free(methods);
        
        if (!implementsSelector) {
            return YES;
        }
    }
    
    return NO;
}
+ (void)replaceImplementationOfSelector:(SEL)selector
                           withSelector:(SEL)swizzledSelector
                               forClass:(Class)cls
                  withMethodDescription:(struct objc_method_description)methodDescription
                    implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock {
    if ([self instanceRespondsButDoesNotImplementSelector:selector class:cls]) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock((id)(
        [cls instancesRespondToSelector:selector] ? implementationBlock : undefinedBlock)
    );
    
    Method oldMethod = class_getInstanceMethod(cls, selector);
    const char *types = methodDescription.types;
    if (oldMethod) {
        if (!types) {
            types = method_getTypeEncoding(oldMethod);
        }

        class_addMethod(cls, swizzledSelector, implementation, types);
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        if (!types) {
            // Some protocol method descriptions don't have .types populated
            // Set the return type to void and ignore arguments
            types = "v@:";
        }
        class_addMethod(cls, selector, implementation, types);
    }
}
+ (BOOL)isErrorStatusCodeFromURLResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        return httpResponse.statusCode >= 400;
    }
    
    return NO;
}
+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response {
    NSString *httpResponseString = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *statusCodeDescription = nil;
        if (httpResponse.statusCode == 200) {
            // Prefer OK to the default "no error"
            statusCodeDescription = @"OK";
        } else {
            statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        }
        httpResponseString = [NSString stringWithFormat:@"%ld %@", (long)httpResponse.statusCode, statusCodeDescription];
    }
    return httpResponseString;
}

+ (NSString *)curlCommandString:(NSURLRequest *)request {
    __block NSMutableString *curlCommandString = [NSMutableString stringWithFormat:@"curl -v -X %@ ", request.HTTPMethod];

    [curlCommandString appendFormat:@"\'%@\' ", request.URL.absoluteString];

    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop) {
        [curlCommandString appendFormat:@"-H \'%@: %@\' ", key, val];
    }];

    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:request.URL];
    if (cookies) {
        [curlCommandString appendFormat:@"-H \'Cookie:"];
        for (NSHTTPCookie *cookie in cookies) {
            [curlCommandString appendFormat:@" %@=%@;", cookie.name, cookie.value];
        }
        [curlCommandString appendFormat:@"\' "];
    }

    if (request.HTTPBody) {
        NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        [curlCommandString appendFormat:@"-d \'%@\'", body];
    }

    return curlCommandString;
}
+ (NSArray<NSURLQueryItem *> *)itemsFromQueryString:(NSString *)query {
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray new];

    // [a=1, b=2, c=3]
    NSArray<NSString *> *queryComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValueString in queryComponents) {
        // [a, 1]
        NSArray<NSString *> *components = [keyValueString componentsSeparatedByString:@"="];
        if (components.count == 2) {
            NSString *key = components.firstObject.stringByRemovingPercentEncoding;
            NSString *value = components.lastObject.stringByRemovingPercentEncoding;

            [items addObject:[NSURLQueryItem queryItemWithName:key value:value]];
        }
    }

    return items.copy;
}
+ (NSString *)stringFromRequestDuration:(NSTimeInterval)duration {
    NSString *string = @"0s";
    if (duration > 0.0) {
        if (duration < 1.0) {
            string = [NSString stringWithFormat:@"%dms", (int)(duration * 1000)];
        } else if (duration < 10.0) {
            string = [NSString stringWithFormat:@"%.2fs", duration];
        } else {
            string = [NSString stringWithFormat:@"%.1fs", duration];
        }
    }
    return string;
}
+ (NSString *)prettyJSONStringFromData:(NSData *)data {
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        // Thanks RaziPour1993
        prettyString = [[NSString alloc]
            initWithData:[NSJSONSerialization
                dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL
            ]
            encoding:NSUTF8StringEncoding
        ];
        // NSJSONSerialization escapes forward slashes.
        // We want pretty json, so run through and unescape the slashes.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString;
}

+ (BOOL)isValidJSONData:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] ? YES : NO;
}
+ (NSData *)inflatedDataFromCompressedData:(NSData *)compressedData {
    NSData *inflatedData = nil;
    NSUInteger compressedDataLength = compressedData.length;
    if (compressedDataLength > 0) {
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uInt)compressedDataLength;
        stream.next_in = (void *)compressedData.bytes;
        stream.total_out = 0;
        stream.avail_out = 0;

        NSMutableData *mutableData = [NSMutableData dataWithLength:compressedDataLength * 1.5];
        if (inflateInit2(&stream, 15 + 32) == Z_OK) {
            int status = Z_OK;
            while (status == Z_OK) {
                if (stream.total_out >= mutableData.length) {
                    mutableData.length += compressedDataLength / 2;
                }
                stream.next_out = (uint8_t *)[mutableData mutableBytes] + stream.total_out;
                stream.avail_out = (uInt)(mutableData.length - stream.total_out);
                status = inflate(&stream, Z_SYNC_FLUSH);
            }
            if (inflateEnd(&stream) == Z_OK) {
                if (status == Z_STREAM_END) {
                    mutableData.length = stream.total_out;
                    inflatedData = [mutableData copy];
                }
            }
        }
    }
    return inflatedData;
}
+ (NSString *)stringByEscapingHTMLEntitiesInString:(NSString *)originalString {
    static NSDictionary<NSString *, NSString *> *escapingDictionary = nil;
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        escapingDictionary = @{ @" " : @"&nbsp;",
                                @">" : @"&gt;",
                                @"<" : @"&lt;",
                                @"&" : @"&amp;",
                                @"'" : @"&apos;",
                                @"\"" : @"&quot;",
                                @"«" : @"&laquo;",
                                @"»" : @"&raquo;"
                                };
        regex = [NSRegularExpression regularExpressionWithPattern:@"(&|>|<|'|\"|«|»)" options:0 error:NULL];
    });
    
    NSMutableString *mutableString = originalString.mutableCopy;
    
    NSArray<NSTextCheckingResult *> *matches = [regex
        matchesInString:mutableString options:0 range:NSMakeRange(0, mutableString.length)
    ];
    for (NSTextCheckingResult *result in matches.reverseObjectEnumerator) {
        NSString *foundString = [mutableString substringWithRange:result.range];
        NSString *replacementString = escapingDictionary[foundString];
        if (replacementString) {
            [mutableString replaceCharactersInRange:result.range withString:replacementString];
        }
    }
    
    return [mutableString copy];
}
+ (NSString *)gold_timeExchange:(CGFloat)time {
    NSInteger hour = (NSInteger)time/3600;
    NSInteger min =  (NSInteger)time%3600/60;
    NSInteger sec = (NSInteger)time%3600%60;
    if (hour) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)min,(long)sec];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)min,(long)sec];
}
+ (CGFloat)getStatusBarHight {
   float statusBarHeight = 0;
   if (@available(iOS 13.0, *)) {
       UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
       statusBarHeight = statusBarManager.statusBarFrame.size.height;
   }
   else {
       statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
   }
   return statusBarHeight;
}
@end

