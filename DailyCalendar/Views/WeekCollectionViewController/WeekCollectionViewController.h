//
//  WeekCollectionViewController.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/1/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeekCollectionViewController : UIViewController

@property (strong, nonatomic) EventStore *eventStore;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
