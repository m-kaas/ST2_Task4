//
//  EventGridLayoutConstants.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

const CGFloat sectionHeight = 35.0;
const CGFloat xOffset = 55.0;
const NSInteger numberOfHours = 24;
const NSInteger minutesInSection = 15;
const NSInteger minutesInHour = 60;
const NSInteger numberOfSectionsInHour = minutesInHour / minutesInSection;
const NSInteger numberOfSections = numberOfHours * numberOfSectionsInHour;
const NSInteger itemZIndex = 1;
const NSInteger decorationZIndex = 0;
NSString * const itemAttributesKey = @"itemAttributesKey";
NSString * const dottedLineAttributesKey = @"dottedLineAttributesKey";
NSString * const dottedLineDecorationViewKind = @"dottedLineDecorationViewKind";
NSString * const sectionTimeAttributesKey = @"sectionTimeAttributesKey";
NSString * const sectionTimeDecorationViewKind = @"sectionTimeDecorationViewKind";
NSString * const eventTimeAttributesKey = @"eventTimeAttributesKey";
NSString * const eventTimeDecorationViewKind = @"eventTimeDecorationViewKind";
NSString * const currentTimeAttributesKey = @"currentTimeAttributesKey";
NSString * const currentTimeDecorationViewKind = @"currentTimeDecorationViewKind";
NSString * const currentTimeLineAttributesKey = @"currentTimeLineAttributesKey";
NSString * const currentTimeLineDecorationViewKind = @"currentTimeLineDecorationViewKind";
