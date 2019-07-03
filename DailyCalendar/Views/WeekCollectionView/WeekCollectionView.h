//
//  WeekCollectionView.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeekCollectionView : UIView

@property (strong, nonatomic) EventStore *eventStore;
@property (strong, nonatomic) NSDate *selectedDate;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
