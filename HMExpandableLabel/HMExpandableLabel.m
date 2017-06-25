//
//  HMExpandableLabel.m
//  HMExpandableLabel
//
//  Created by 伍学俊 on 2017/6/23.
//  Copyright © 2017年 伍学俊. All rights reserved.
//

#import "HMExpandableLabel.h"
#import <CoreText/CoreText.h>

@interface NSAttributedString (HMExpandable)

- (CFArrayRef)hm_linesForWidth:(CGFloat)width;
- (CGRect)hm_boundingRectForWidth:(CGFloat)width;

@end

@interface HMExpandableLabel ()

@property (nonatomic, copy) NSString *originText;
@property (nonatomic, assign) CGRect linkRect;

@end

@implementation HMExpandableLabel

@synthesize expanded = _expanded;

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark -

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches allObjects].firstObject locationInView:self];
    if (CGRectContainsPoint(self.linkRect, location)) {
        BOOL isExpanded = self.isExpanded;
        self.expanded = !self.isExpanded;
        if (isExpanded) {
            NSLog(@"准备收起");
            if ([_delegate respondsToSelector:@selector(hmExpandableLabelDidPackup:)]) {
                [_delegate hmExpandableLabelDidPackup:self];
            }
        } else {
            NSLog(@"准备展开");
            if ([_delegate respondsToSelector:@selector(hmExpandableLabelDidExpand:)]) {
                [_delegate hmExpandableLabelDidExpand:self];
            }
        }
    }
}

#pragma mark private api

- (void)commonInit
{
    self.userInteractionEnabled = YES;
    self.packupLineCount = 3;
    self.numberOfLines = 0;
    self.font = [UIFont systemFontOfSize:16.0];
    self.textColor = [UIColor blackColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    self.packupLinkString = [[NSAttributedString alloc] initWithString:@"收起" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                          NSFontAttributeName : self.font,
                                                                                          NSParagraphStyleAttributeName : paragraphStyle}];
    self.expandLinkString = [[NSAttributedString alloc] initWithString:@"更多" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor],
                                                                                          NSFontAttributeName : self.font}];
}

- (NSDictionary *)commonAttributes
{
    return @{NSFontAttributeName : self.font,
             NSForegroundColorAttributeName : self.textColor};
}

/**
 * 当前正文文本的属性
 */
- (NSDictionary *)currentAttribute
{
    NSMutableDictionary *attribute = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.font) [attribute setObject:self.font forKey:NSFontAttributeName];
    if (self.textColor) [attribute setObject:self.textColor forKey:NSForegroundColorAttributeName];
    return attribute;
}

/**
 * 获取展开状态下的文本
 */
- (NSAttributedString *)getAttributeStringInExpandStatus:(NSAttributedString *)originAttributeString
                                     linkAttributeString:(NSAttributedString *)linkAttributeString
                                                linkRect:(CGRect *)linkRect
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithAttributedString:originAttributeString];
    CGRect stringBounds = [attributeString hm_boundingRectForWidth:self.frame.size.width];
    [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:[self commonAttributes]]];
    CGRect curLinkRect = [linkAttributeString hm_boundingRectForWidth:self.frame.size.width];
    curLinkRect = CGRectMake(self.frame.size.width - curLinkRect.size.width,
                             stringBounds.origin.y + stringBounds.size.height,
                             curLinkRect.size.width,
                             curLinkRect.size.height);
    [attributeString appendAttributedString:linkAttributeString];
    curLinkRect = CGRectInset(curLinkRect, -5, -5);
    if (linkRect) (*linkRect) = curLinkRect;
    return attributeString;
}

/**
 * 获取收起状态下的文本
 */
- (NSAttributedString *)getAttributeStringInPackupStatus:(NSAttributedString *)originAttributeString
                                     linkAttributeString:(NSAttributedString *)linkAttributeString
                                            maxLineCount:(NSInteger)maxLineCount
                                                linkRect:(CGRect *)linkRect
{
    // 计算显示的行数
    CFArrayRef lines = [originAttributeString hm_linesForWidth:self.frame.size.width];
    NSInteger lineCount = CFArrayGetCount(lines);
    if (lineCount <= maxLineCount) {
        return originAttributeString;
    }
    NSMutableAttributedString *newAttributeString = [[NSMutableAttributedString alloc] init];
    for (NSInteger index = 0; index < maxLineCount - 1; index ++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, index);
        CFRange range = CTLineGetStringRange(line);
        NSAttributedString *lineString = [originAttributeString attributedSubstringFromRange:NSMakeRange(range.location, range.length)];
        [newAttributeString appendAttributedString:lineString];

    }
    __block CGRect curLinkRect = [linkAttributeString hm_boundingRectForWidth:self.frame.size.width];
    // 最后一行
    CTLineRef lastLine = CFArrayGetValueAtIndex(lines, maxLineCount - 1);
    CFRange range = CTLineGetStringRange(lastLine);
    NSAttributedString *attributeString = [originAttributeString attributedSubstringFromRange:NSMakeRange(range.location, range.length)];
    [attributeString.string enumerateSubstringsInRange:NSMakeRange(0, attributeString.string.length) options:NSStringEnumerationReverse | NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSMutableAttributedString *tempAttributeString = [attributeString attributedSubstringFromRange:NSMakeRange(0, substringRange.location)].mutableCopy;
        [tempAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" ... " attributes:[self commonAttributes]]];
        CGRect tempStringRect = [tempAttributeString hm_boundingRectForWidth:self.frame.size.width];
        [tempAttributeString appendAttributedString:linkAttributeString];
        CGRect tempRect = [tempAttributeString hm_boundingRectForWidth:MAXFLOAT];
        if (tempRect.size.width < self.frame.size.width) {
            [newAttributeString appendAttributedString:tempAttributeString];
            (*stop) = YES;
            curLinkRect = CGRectMake(tempStringRect.origin.x + tempStringRect.size.width, self.font.lineHeight * (maxLineCount - 1), curLinkRect.size.width, curLinkRect.size.height);
        }
    }];
    curLinkRect = CGRectInset(curLinkRect, -5, -5);
    if (linkRect) (*linkRect) = curLinkRect;
    return newAttributeString;
}

#pragma mark override

- (void)setText:(NSString *)text
{
    self.linkRect = CGRectZero;
    if (!text.length) {
        self.attributedText = nil;
    } else {
        self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self commonAttributes]];
    }
}

- (NSString *)text
{
    return self.originText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.originText = attributedText.string;
    if (!attributedText.length) return;
    CGRect linkRect = CGRectZero;
    if (self.isExpanded) {
        NSAttributedString *expandAttributeString = [self getAttributeStringInExpandStatus:attributedText
                                                                       linkAttributeString:self.packupLinkString
                                                                                  linkRect:&linkRect];
        [super setAttributedText:expandAttributeString];
    } else {
        NSAttributedString *packupAttributeString = [self getAttributeStringInPackupStatus:attributedText
                                                                       linkAttributeString:self.expandLinkString
                                                                              maxLineCount:self.packupLineCount
                                                                                  linkRect:&linkRect];
        [super setAttributedText:packupAttributeString];
    }
    self.linkRect = linkRect;
}

- (void)setExpanded:(BOOL)expanded
{
    _expanded = expanded;
    [self setText:_originText];
}

- (void)setPackupLinkString:(NSAttributedString *)packupLinkString
{
    if (!packupLinkString) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSMutableAttributedString *newAttributeString = packupLinkString.mutableCopy;
    [newAttributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, packupLinkString.length)];
    _packupLinkString = newAttributeString.copy;
}

@end

@implementation NSAttributedString (HMExpandable)

- (CFArrayRef)hm_linesForWidth:(CGFloat)width
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, MAXFLOAT)];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path.CGPath, nil);
    CFArrayRef lines = CTFrameGetLines(frame);
    return lines;
}

- (CGRect)hm_boundingRectForWidth:(CGFloat)width
{
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
}

@end
