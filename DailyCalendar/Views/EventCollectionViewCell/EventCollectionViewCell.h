//
//  EventCollectionViewCell.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) EKEvent *event;

@end

NS_ASSUME_NONNULL_END
