//
//  DesignHelper.m
//  EmptyObjCApp
//
//  Created by USER_NAME on CURRENT_DATE.
//  Copyright © CURRENT_YEAR COMPANY_NAME. All rights reserved.
//

#import "DesignHelper.h"

@interface DesignDefault : ACDesign
@end
@implementation DesignDefault
+ (NSDictionary *)design {
    return @{  };
}
@end

@implementation DesignHelper

+ (void)applyDesign:(DesignType)type {
    switch (type) {
        default:{
            [self setDesignClass:[DesignDefault class]];
            break;
        }
    }
}

@end
