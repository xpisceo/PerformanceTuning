//
//  PerformanceTuningAppDelegate.h
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"

@class PerformanceTuningViewController;

@interface PerformanceTuningAppDelegate : NSObject <UIApplicationDelegate> {
	DBManager *dbMgr;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PerformanceTuningViewController *viewController;
- (void)loadData; 
- (NSManagedObject *)insertObjectForName:(NSString *)entityName withName:(NSString *)name;
@end
