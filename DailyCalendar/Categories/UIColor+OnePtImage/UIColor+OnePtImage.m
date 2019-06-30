//
//  UIColor+OnePtImage.m
//  ContactsTable
//
//  Created by Liubou Sakalouskaya on 6/10/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "UIColor+OnePtImage.h"

@implementation UIColor (OnePtImage)

- (UIImage *)onePtImage {
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self setFill];
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
