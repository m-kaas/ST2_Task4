//
//  UIColor+CustomColors.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

+ (UIColor *)colorFromHex:(int)hexValue {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)customDarkBlueColor {
    return [UIColor colorFromHex:0x037594];
}

+ (UIColor *)customWhiteColor {
    return [UIColor colorFromHex:0xFFFFFF];
}

+ (UIColor *)customRedColor {
    return [UIColor colorFromHex:0xFC6769];
}

+ (UIColor *)customDarkGrayColor {
    return [UIColor colorFromHex:0x383838];
}

+ (UIColor *)customLightGrayColor {
    return [UIColor colorFromHex:0xC7C7C8];
}

+ (UIColor *)customBlackColor {
    return [UIColor colorFromHex:0x000000];
}

@end
