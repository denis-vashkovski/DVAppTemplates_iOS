//
//  DesignHelper.h
//  EmptyObjCApp
//
//  Created by USER_NAME on CURRENT_DATE.
//  Copyright © CURRENT_YEAR COMPANY_NAME. All rights reserved.
//

#import <ACDesignHelper.h>

typedef enum {
    DesignTypeDefault
} DesignType;

@interface DesignHelper : ACDesignHelper
+ (void)applyDesign:(DesignType)type;
@end
