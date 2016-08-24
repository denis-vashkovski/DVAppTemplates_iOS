//
//  AppDelegate.m
//  EmptyObjCApp
//
//  Created by USER_NAME on CURRENT_DATE.
//  Copyright © CURRENT_YEAR COMPANY_NAME. All rights reserved.
//

#import "AppDelegate.h"

#import "DesignHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    [self initGlobalDesign];
    
    return YES;
}

- (void)initGlobalDesign {
    [DesignHelper applyDesign:DesignTypeDefault];
}

@end
