//
//  TimeLabelViewLayoutAttributes.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "TimeLabelViewLayoutAttributes.h"

@implementation TimeLabelViewLayoutAttributes

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TimeLabelViewLayoutAttributes class]]) {
        TimeLabelViewLayoutAttributes *attr = (TimeLabelViewLayoutAttributes *)object;
        if ([self.timeText isEqualToString:attr.timeText]) {
            return [super isEqual:object];
        }
    }
    return NO;
}

@end
