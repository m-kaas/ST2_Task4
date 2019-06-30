//
//  WeeklyCollectionViewCell.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/30/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "WeeklyCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@interface WeeklyCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@end

@implementation WeeklyCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dateLabel.textColor = [UIColor customWhiteColor];
    self.dateLabel.font = [UIFont system17SemiboldFont];
    self.dayLabel.textColor = [UIColor customWhiteColor];
    self.dayLabel.font = [UIFont system12RegularFont];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor customRedColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setDate:(NSDate *)date {
    if (_date != date) {
        _date = date;
    }
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    self.dateLabel.text = [NSString stringWithFormat:@"%ld", dateComponents.day];
    self.dayLabel.text = [NSCalendar currentCalendar].shortWeekdaySymbols[dateComponents.weekday - 1].uppercaseString;
}

@end
