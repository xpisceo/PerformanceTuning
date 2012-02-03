//
//  PerformanceTuningAppDelegate.m
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerformanceTuningAppDelegate.h"

#import "PerformanceTuningViewController.h"

@implementation PerformanceTuningAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	dbMgr = [DBManager shareInstance];
	[self loadData];
    
	 
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

- (void)dealloc
{
	[_window release];
	[_viewController release];
    [super dealloc];
}

- (void)loadData
{
	// Pull the movies. If we have 200, assume our db is set up. 
	NSManagedObjectContext *context = [dbMgr managedObjectContext]; 
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context]];
	NSArray *results = [context executeFetchRequest:request error:nil]; 
	if ([results count] != 200) {
		// Add 200 actors, movies, and studios 
		for (int i = 1; i <= 200; i++) {
			[self insertObjectForName:@"Actor" withName:[NSString stringWithFormat: @"Actor %d", i]];
			[self insertObjectForName:@"Movie" withName:[NSString stringWithFormat: @"Movie %d", i]];
			[self insertObjectForName:@"Studio" withName:[NSString stringWithFormat: @"Studio %d", i]];
			}
	}
	[request release];
	
	//Relate all the actors and all the studios to all the movies 
	{
		NSManagedObjectContext *context = [dbMgr managedObjectContext]; 
		NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
		[request setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context]];
		NSArray *results = [context executeFetchRequest:request error:nil]; 
		for (NSManagedObject *movie in results) {
			[request setEntity:[NSEntityDescription entityForName:@"Actor" inManagedObjectContext:context]];
			NSArray *actors = [context executeFetchRequest:request error:nil];
			NSMutableSet *set = [movie mutableSetValueForKey:@"actors"]; 
			[set addObjectsFromArray:actors];
			[request setEntity:[NSEntityDescription entityForName:@"Studio" inManagedObjectContext:context]];
			NSArray *studios = [context executeFetchRequest:request error:nil]; 
			set = [movie mutableSetValueForKey:@"studios"]; 
			[set addObjectsFromArray:studios];
		} 
		[request release];
	}
	
	NSError *error = nil; 
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]); 
		abort();
	}
}

- (NSManagedObject *)insertObjectForName:(NSString *)entityName withName:(NSString *)name
{
	NSManagedObjectContext *context = [dbMgr managedObjectContext];
	NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	[object setValue:name forKey:@"name"];
	[object setValue:[NSNumber numberWithInteger:((arc4random() % 10) + 1)] forKey:@"rating"];
	return object;
}

@end
