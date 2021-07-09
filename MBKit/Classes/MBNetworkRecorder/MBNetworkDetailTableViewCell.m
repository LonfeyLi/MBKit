//
//  MBNetworkDetailTableViewCell.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/22.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkDetailTableViewCell.h"
@interface MBNetworkDetailTableViewCell ()
@property (nonatomic, readonly) UILabel *_titleLabel;
@property (nonatomic, readonly) UILabel *_subtitleLabel;
@property (nonatomic) BOOL constraintsUpdated;
@end
@implementation MBNetworkDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}
- (void)postInit {
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:13.f];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.f];
    self.detailTextLabel.textColor = UIColor.lightGrayColor;
    self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
}

+ (UIEdgeInsets)labelInsets {
    return UIEdgeInsetsMake(10.0, 16.0, 10.0, 8.0);
}

+ (CGFloat)preferredHeightWithAttributedText:(NSAttributedString *)attributedText
                                    maxWidth:(CGFloat)contentViewWidth
                                       style:(UITableViewStyle)style
                              showsAccessory:(BOOL)showsAccessory {
    CGFloat labelWidth = contentViewWidth;

    // Content view inset due to accessory view observed on iOS 8.1 iPhone 6.
    if (showsAccessory) {
        labelWidth -= 34.0;
    }

    UIEdgeInsets labelInsets = [self labelInsets];
    labelWidth -= (labelInsets.left + labelInsets.right);

    CGSize constrainSize = CGSizeMake(labelWidth, CGFLOAT_MAX);
    CGRect boundingBox = [attributedText boundingRectWithSize:constrainSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat preferredLabelHeight =  floor(boundingBox.size.height);
    CGFloat preferredCellHeight = preferredLabelHeight + labelInsets.top + labelInsets.bottom + 1.0;

    return preferredCellHeight;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

