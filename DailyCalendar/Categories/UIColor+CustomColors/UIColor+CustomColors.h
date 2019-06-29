//
//  UIColor+CustomColors.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CustomColors)

+ (UIColor *)colorFromHex:(int)hexValue;
+ (UIColor *)customDarkBlueColor;
+ (UIColor *)customWhiteColor;
+ (UIColor *)customRedColor;
+ (UIColor *)customDarkGrayColor;
+ (UIColor *)customLightGrayColor;
+ (UIColor *)customBlackColor;

@end

NS_ASSUME_NONNULL_END
