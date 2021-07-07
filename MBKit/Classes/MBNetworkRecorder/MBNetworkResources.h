//
//  MBNetworkResources.h
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/21.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//

#ifndef RELEASE

#import <Foundation/Foundation.h>
typedef UIViewController *(^MBNetworkDetailRowSelectionFuture)(void);
NS_ASSUME_NONNULL_BEGIN
@class MBNetworkDetailRow;
@interface MBNetworkResources : NSObject
#pragma mark - Toolbar Icons

@property (readonly, class) UIImage *closeIcon;
@property (readonly, class) UIImage *dragHandle;
@property (readonly, class) UIImage *globalsIcon;
@property (readonly, class) UIImage *hierarchyIcon;
@property (readonly, class) UIImage *recentIcon;
@property (readonly, class) UIImage *moveIcon;
@property (readonly, class) UIImage *selectIcon;

@property (readonly, class) UIImage *bookmarksIcon;
@property (readonly, class) UIImage *openTabsIcon;
@property (readonly, class) UIImage *moreIcon;
@property (readonly, class) UIImage *gearIcon;
@property (readonly, class) UIImage *scrollToBottomIcon;

#pragma mark - Content Type Icons

@property (readonly, class) UIImage *jsonIcon;
@property (readonly, class) UIImage *textPlainIcon;
@property (readonly, class) UIImage *htmlIcon;
@property (readonly, class) UIImage *audioIcon;
@property (readonly, class) UIImage *jsIcon;
@property (readonly, class) UIImage *plistIcon;
@property (readonly, class) UIImage *textIcon;
@property (readonly, class) UIImage *videoIcon;
@property (readonly, class) UIImage *xmlIcon;
@property (readonly, class) UIImage *binaryIcon;

#pragma mark - 3D Explorer Icons

@property (readonly, class) UIImage *toggle2DIcon;
@property (readonly, class) UIImage *toggle3DIcon;
@property (readonly, class) UIImage *rangeSliderLeftHandle;
@property (readonly, class) UIImage *rangeSliderRightHandle;
@property (readonly, class) UIImage *rangeSliderTrack;
@property (readonly, class) UIImage *rangeSliderFill;

#pragma mark - Misc Icons

@property (readonly, class) UIImage *checkerPattern;
@property (readonly, class) UIColor *checkerPatternColor;
@property (readonly, class) UIImage *hierarchyIndentPattern;
@end

#pragma mark - MBNetworkDetail
@interface MBNetworkDetailRow : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) MBNetworkDetailRowSelectionFuture selectionFuture;

@end

@interface MBNetworkDetailSection : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<MBNetworkDetailRow *> *rows;

@end



NS_ASSUME_NONNULL_END

#endif
