//
//  ViewController.m
//  HMExpandableLabel
//
//  Created by 伍学俊 on 2017/6/23.
//  Copyright © 2017年 伍学俊. All rights reserved.
//

#import "ViewController.h"
#import "HMExpandableLabel.h"

@interface ViewController () <HMExpandableLabelDelegate>

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    HMExpandableLabel *label = [[HMExpandableLabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 30)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.packupLineCount = 4;
    label.expanded = NO;
    label.expandLinkString = [[NSAttributedString alloc] initWithString:@"更多" attributes:@{NSForegroundColorAttributeName : [UIColor brownColor], NSFontAttributeName : label.font}];
    label.packupLinkString = [[NSAttributedString alloc] initWithString:@"收起" attributes:@{NSForegroundColorAttributeName : [UIColor brownColor], NSFontAttributeName : label.font}];
    label.text = @"我们 On third line our text need be collapsed because we have ordinary text, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.";
    [self.view addSubview:label];
    label.delegate = self;
    label.backgroundColor = [UIColor yellowColor];
    [label sizeToFit];
    self.label = label;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark HMExpandableLabelDelegate

- (void)hmExpandableLabelDidExpand:(HMExpandableLabel *)label
{
    [label sizeToFit];
}

- (void)hmExpandableLabelDidPackup:(HMExpandableLabel *)label
{
    [label sizeToFit];
}

@end
