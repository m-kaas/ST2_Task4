//
//  UIFont+CustomFonts.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "UIFont+CustomFonts.h"

@implementation UIFont (CustomFonts)

+ (UIFont *)system12RegularFont {
    return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
}

+ (UIFont *)system15RegularFont {
    return [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
}

+ (UIFont *)system17RegularFont {
    return [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
}

+ (UIFont *)system17MediumFont {
    return [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
}

+ (UIFont *)system17SemiboldFont {
    return [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
}

@end
