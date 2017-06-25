//
//  HMExpandableLabel.h
//  HMExpandableLabel
//
//  Created by 伍学俊 on 2017/6/23.
//  Copyright © 2017年 伍学俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMExpandableLabel;

@protocol HMExpandableLabelDelegate <NSObject>

@optional

- (void)hmExpandableLabelDidExpand:(HMExpandableLabel *)label;
- (void)hmExpandableLabelDidPackup:(HMExpandableLabel *)label;

@end

/**
 * 可以支持展开和收起的标签
 * Note: 
 * 目前控件做的不是特别完善，所以任何属性的设置，包括textcolor、font等等，
 * 请统一放在初始化的时候进行，也就是说，放在设置text之前进行属性的初始化
 */
@interface HMExpandableLabel : UILabel

#pragma mark -

@property (nonatomic, weak) id<HMExpandableLabelDelegate> delegate;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;  // 是否展开，默认NO，收起状态
@property (nonatomic, assign) NSInteger packupLineCount;        // 收起状态下显示的行数，默认为3
@property (nonatomic, copy) NSAttributedString *packupLinkString;
@property (nonatomic, copy) NSAttributedString *expandLinkString;

@end
