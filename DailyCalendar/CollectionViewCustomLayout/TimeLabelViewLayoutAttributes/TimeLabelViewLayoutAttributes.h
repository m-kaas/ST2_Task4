//
//  TimeLabelViewLayoutAttributes.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeLabelViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (copy, nonatomic) NSString *timeText;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
