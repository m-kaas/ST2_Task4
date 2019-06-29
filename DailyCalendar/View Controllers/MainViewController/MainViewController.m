//
//  MainViewController.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "MainViewController.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor customDarkBlueColor];
    [self.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor customWhiteColor],
                                                  NSFontAttributeName: [UIFont system17SemiboldFont] }];
}

@end
