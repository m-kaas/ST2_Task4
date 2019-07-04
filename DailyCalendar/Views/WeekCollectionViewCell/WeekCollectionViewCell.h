//
//  WeekCollectionViewCell.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/30/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeekCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dotLabel;

@end

NS_ASSUME_NONNULL_END
